# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Carton do
  let(:carton) { create(:carton) }

  describe 'shipping method' do
    it 'returns soft deleted shipping method' do
      carton = create(:carton)
      carton.shipping_method.discard
      expect(carton.reload.shipping_method).to be_present
    end
  end

  describe "#create" do
    subject { carton }

    it "raises no errors" do
      subject
    end
  end

  describe "#tracking_url" do
    subject do
      carton.tracking_url
    end

    let(:carton) { create(:carton, shipping_method: shipping_method) }
    let(:shipping_method) do
      create(:shipping_method, tracking_url: "https://example.com/:tracking")
    end

    context "when tracking is not present" do
      it { is_expected.to be_nil }
    end

    context "when tracking is present" do
      let(:carton) do
        create(:carton, shipping_method: shipping_method, tracking: "1Z12345")
      end

      it "uses shipping method to determine url" do
        is_expected.to eq("https://example.com/1Z12345")
      end
    end
  end

  describe "#to_param" do
    subject do
      carton.to_param
    end

    it { is_expected.to eq carton.number }
  end

  describe "#order_numbers" do
    subject { carton.order_numbers }
    let(:order) { carton.orders.first }

    it "returns a list of the order numbers it is associated to" do
      expect(subject).to eq [order.number]
    end
  end

  describe "#shipment_numbers" do
    subject { carton.shipment_numbers }
    let(:shipment) { carton.shipments.first }

    it "returns a list of the shipment numbers it is associated to" do
      expect(subject).to eq [shipment.number]
    end
  end

  describe "#order_emails" do
    subject { carton.order_emails }

    let(:carton) { create(:carton, inventory_units: [first_order.inventory_units, second_order.inventory_units].flatten) }
    let(:first_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:second_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:email) { 'something@something.com' }

    before do
      first_order.update!(email: email)
      second_order.update!(email: email)
    end

    it "returns a unique list of the order emails it is associated to" do
      expect(subject).to eq [email]
    end
  end

  describe "#manifest" do
    subject { carton.manifest }

    let(:carton) { create(:carton, inventory_units: [first_order.inventory_units, second_order.inventory_units].flatten) }
    let(:first_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:first_line_item) { first_order.line_items.first }
    let(:second_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:second_line_item) { second_order.line_items.first }

    it "contains only the items in both the carton and order" do
      expect(subject.map(&:line_item)).to match_array([first_line_item, second_line_item])
    end
  end

  describe "#manifest_for_order" do
    subject { carton.manifest_for_order(first_order) }

    let(:carton) { create(:carton, inventory_units: [first_order.inventory_units, second_order.inventory_units].flatten) }
    let(:first_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:first_line_item) { first_order.line_items.first }
    let(:second_order) { create(:order_ready_to_ship, line_items_count: 1) }

    it "contains only the items in both the carton and order" do
      expect(subject.map(&:line_item)).to eq [first_line_item]
    end
  end

  describe "#any_exchanges?" do
    subject { carton.any_exchanges? }

    let(:carton) { create(:carton, inventory_units: [first_order.inventory_units, second_order.inventory_units].flatten) }
    let(:first_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:second_order) { create(:order_ready_to_ship, line_items_count: 1) }

    context "when any of the inventory has an original return item" do
      let(:return_item) { create(:return_item) }
      before do
        first_order.inventory_units.first.original_return_item = return_item
        first_order.save
      end

      it "is true" do
        expect(subject).to be_truthy
      end
    end

    context "when none of the inventory has an original return item" do
      it "is false" do
        expect(subject).to be_falsey
      end
    end
  end
end
