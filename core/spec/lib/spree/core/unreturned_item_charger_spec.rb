require 'spec_helper'

describe Spree::UnreturnedItemCharger do
  let(:ship_address) { create(:address) }
  let(:shipped_order) { create(:shipped_order, ship_address: ship_address, line_items_count: 1, with_cartons: false) }
  let(:original_shipment) { shipped_order.shipments.first }
  let(:original_stock_location) { original_shipment.stock_location }
  let(:original_inventory_unit) { shipped_order.inventory_units.first }
  let(:original_variant) { original_inventory_unit.variant }
  let(:shipping_method) { create(:shipping_method, tax_category: original_variant.tax_category) }

  let(:exchange_shipment) do
    create(:shipment,
           order: shipped_order,
           state: 'shipped',
           stock_location: original_stock_location,
           created_at: 5.days.ago,
           shipping_method: shipping_method)
  end
  let(:exchange_inventory_unit) { exchange_shipment.inventory_units.first }
  let(:return_item) do
    create(:exchange_return_item,
           inventory_unit: original_inventory_unit,
           exchange_inventory_unit: exchange_inventory_unit)
  end

  let!(:unreturned_item_charger) { Spree::UnreturnedItemCharger.new(exchange_shipment, [return_item]) }

  before do
    exchange_shipment.finalize!
    exchange_inventory_unit.ship!
  end

  shared_examples 'charge_for_items success' do
    let(:new_order) do
      subject
      exchange_inventory_unit.shipment.order.reload
    end

    it "reuses the same inventory unit" do
      expect { subject }.not_to change { Spree::InventoryUnit.count }
    end

    it "reuses the same shipment" do
      expect { subject }.not_to change { Spree::Shipment.count }
      expect(new_order.shipments.count).to eq 1
    end

    context 'in tax zone' do
      let!(:tax_zone) { create(:zone, countries: [ship_address.country]) }
      let!(:tax_rate) { create(:tax_rate, zone: tax_zone, tax_category: original_variant.tax_category) }
      before { tax_zone.update_attributes!(default_tax: true) }

      it "applies tax" do
        exchange_order = exchange_shipment.order
        exchange_order.create_tax_charge!
        exchange_order.update!
        subject
        expect(new_order.additional_tax_total).to be > 0
        expect(new_order.line_items[0].additional_tax_total).to be > 0
        expect(new_order.shipments[0].additional_tax_total).to be > 0
      end
    end

    it "creates a new completed order" do
      expect { subject }.to change { Spree::Order.count }.by(1)
      expect(new_order).to_not eq(shipped_order)
      expect(new_order).to be_completed
    end

    it "authorizes payment" do
      expect { subject }.to change { Spree::Payment.count }.by(1)
      expect(new_order.payments.count).to eq 1
      expect(new_order.payments.first).to be_pending
      expect(new_order.payments.first.response_code).to be_present
    end

    it "delivers confirmation email" do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    context 'with auto_capture_exchanges' do
      before { Spree::Config[:auto_capture_exchanges] = true }

      it "captures payment" do
        expect { subject }.to change { Spree::Payment.count }.by(1)
        expect(new_order.payments.count).to eq 1
        expect(new_order.payments.first).to be_completed
        expect(new_order.payment_state).to eq "paid"
      end
    end
  end

  describe "#charge_for_items" do
    before do
      original_variant.update_attributes!(track_inventory: true)
      original_variant.stock_items.update_all(backorderable: false)
    end

    subject { unreturned_item_charger.charge_for_items }

    context "new order is not an unreturned exchange" do
      before do
        allow_any_instance_of(Spree::Shipment).to receive(:update_attributes!)
      end

      it "raises an error" do
        expect { subject }.to raise_error(Spree::UnreturnedItemCharger::ChargeFailure, 'order is not an unreturned exchange')
      end
    end

    context "item is in stock" do
      before do
        original_variant.stock_items.map { |si| si.set_count_on_hand(10) }
      end

      include_examples 'charge_for_items success'
    end

    context "item is now out of stock" do
      before do
        original_variant.stock_items.map { |si| si.set_count_on_hand(0) }
      end

      include_examples 'charge_for_items success'
    end
  end
end
