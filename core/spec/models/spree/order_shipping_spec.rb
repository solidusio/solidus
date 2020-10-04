# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderShipping do
  include ActiveSupport::Testing::TimeHelpers

  let(:order) { create(:order_ready_to_ship, line_items_count: 1) }

  def emails
    ActionMailer::Base.deliveries
  end

  shared_examples 'shipment shipping' do
    it "marks the inventory units as shipped" do
      expect { subject }.to change { order.inventory_units.reload.map(&:state) }.from(['on_hand']).to(['shipped'])
    end

    it "creates a carton with the shipment's inventory units" do
      expect { subject }.to change { order.cartons.count }.by(1)
      expect(subject.inventory_units).to match_array(shipment.inventory_units)
    end

    describe "shipment email" do
      it "should send a shipment email" do
        expect {
          perform_enqueued_jobs {
            subject
          }
        }.to change { emails.size }.by(1)
        expect(emails.last.subject).to eq("#{order.store.name} Shipment Notification ##{order.number}")
      end
    end

    it "updates the order shipment state" do
      expect { subject }.to change { order.reload.shipment_state }.from('ready').to('shipped')
    end

    it "updates shipment.shipped_at" do
      now = Time.current
      travel_to(now) do
        expect { subject }.to change { shipment.shipped_at }.from(nil).to be_within(1.second).of(now)
      end
    end

    it "updates order.updated_at" do
      future = 1.minute.from_now
      expect do
        travel_to(future) do
          subject
        end
      end.to change { order.updated_at }.to be_within(1.second).of(future)
    end
  end

  describe "#ship" do
    subject do
      order.shipping.ship(
        inventory_units: inventory_units,
        stock_location: stock_location,
        address: address,
        shipping_method: shipping_method
      )
    end

    let(:shipment) { order.shipments.to_a.first }
    let(:inventory_units) { shipment.inventory_units }
    let(:stock_location) { shipment.stock_location }
    let(:address) { order.ship_address }
    let(:shipping_method) { shipment.shipping_method }

    it_behaves_like 'shipment shipping'

    context "with an external_number" do
      subject do
        order.shipping.ship(
          inventory_units: inventory_units,
          stock_location: stock_location,
          address: address,
          shipping_method: shipping_method,
          external_number: 'some-external-number'
        )
      end

      it "sets the external_number" do
        expect(subject.external_number).to eq 'some-external-number'
      end
    end

    context "with a tracking number" do
      subject do
        order.shipping.ship(
          inventory_units: inventory_units,
          stock_location: stock_location,
          address: address,
          shipping_method: shipping_method,
          tracking_number: 'tracking-number'
        )
      end

      it "sets the tracking-number" do
        expect(subject.tracking).to eq 'tracking-number'
      end
    end

    context "when told to suppress the mailer" do
      subject do
        order.shipping.ship(
          inventory_units: inventory_units,
          stock_location: stock_location,
          address: address,
          shipping_method: shipping_method,
          suppress_mailer: true
        )
      end

      it "does not send a shipment email" do
        expect { subject }.to_not change { emails.size }
      end
    end
  end

  describe "#ship_shipment" do
    subject { order.shipping.ship_shipment(shipment) }

    let(:shipment) { order.shipments.to_a.first }

    it_behaves_like 'shipment shipping'

    context "when not all units are shippable" do
      let(:order) { create(:order_ready_to_ship, line_items_count: 2) }
      let(:shippable_line_item) { order.line_items.first }
      let(:unshippable_line_item) { order.line_items.last }

      before do
        unshippable_line_item.inventory_units.each(&:cancel!)
      end

      it "only ships the shippable ones" do
        expect(subject.inventory_units).to match_array(shippable_line_item.inventory_units)
      end
    end

    context "when all units are canceled or shipped" do
      let(:order) { create(:order_ready_to_ship, line_items_count: 2) }

      before { Spree::OrderCancellations.new(order).short_ship([order.inventory_units.first]) }

      it "updates the order shipment state" do
        expect { subject }.to change { order.reload.shipment_state }.from('ready').to('shipped')
      end
    end

    context "with an external_number" do
      subject do
        order.shipping.ship_shipment(
          shipment,
          external_number: 'some-external-number'
        )
      end

      it "sets the external_number" do
        expect(subject.external_number).to eq 'some-external-number'
      end
    end

    context "with a tracking number" do
      subject do
        order.shipping.ship_shipment(
          shipment,
          tracking_number: 'tracking-number'
        )
      end

      it "sets the tracking-number" do
        expect(subject.tracking).to eq 'tracking-number'
      end
    end

    # TODO: We can remove this once Shipment#ship! is called by
    # OrderShipping#ship rather than vice versa
    context "when the tracking number is already on the shipment" do
      before do
        shipment.update!(tracking: 'tracking-number')
      end

      it "sets the tracking-number" do
        expect(subject.tracking).to eq 'tracking-number'
      end
    end

    context "when the shipment has been partially shipped previously" do
      let(:order) { create(:order_ready_to_ship, line_items_count: 2) }
      let(:inventory_units) { shipment.inventory_units.to_a }
      let(:shipped_inventory) { [inventory_units.first] }
      let(:unshipped_inventory) { [inventory_units.last] }

      before do
        order.shipping.ship(
          inventory_units: shipped_inventory,
          stock_location: shipment.stock_location,
          address: order.ship_address,
          shipping_method: shipment.shipping_method
        )
      end

      it "marks the inventory units as shipped" do
        expect { subject }.to change { unshipped_inventory.map(&:reload).map(&:state) }.from(['on_hand']).to(['shipped'])
      end

      it "creates a carton with the shipment's inventory units" do
        expect { subject }.to change { order.cartons.count }.by(1)
        expect(subject.inventory_units).to match_array(unshipped_inventory)
      end
    end

    context "when told to suppress the mailer" do
      subject do
        order.shipping.ship_shipment(
          shipment,
          suppress_mailer: true
        )
      end

      it "does not send a shipment email" do
        expect { subject }.to_not change { emails.size }
      end
    end

    context "with stale inventory units (regression test)" do
      let(:order) { FactoryBot.create(:order_ready_to_ship, line_items_count: 1) }
      let(:shipment) do
        FactoryBot.create(
          :shipment,
          order: order
        )
      end

      before { shipment.ready! }

      it "updates the state to shipped" do
        order.shipping.ship_shipment(shipment)
        expect(shipment.reload.state).to eq "shipped"
      end
    end
  end
end
