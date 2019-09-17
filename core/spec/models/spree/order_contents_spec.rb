# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderContents, type: :model do
  let!(:store) { create :store }
  let(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let!(:stock_location) { variant.stock_locations.first }
  let(:stock_location_2) { create(:stock_location) }

  subject(:order_contents) { described_class.new(order) }

  context "#add" do
    context 'given quantity is not explicitly provided' do
      it 'should add one line item' do
        line_item = subject.add(variant)
        expect(line_item.quantity).to eq(1)
        expect(order.line_items.size).to eq(1)
      end
    end

    context 'given a shipment' do
      let!(:shipment) { create(:shipment, order: order) }

      it "ensure shipment calls update_amounts instead of order calling ensure_updated_shipments" do
        expect(subject.order).to_not receive(:ensure_updated_shipments)
        expect(shipment).to receive(:update_amounts)
        subject.add(variant, 1, shipment: shipment)
      end

      context "with quantity=1" do
        it "creates correct inventory" do
          subject.add(variant, 1, shipment: shipment)
          expect(order.inventory_units.count).to eq(1)
        end
      end

      context "with quantity=2" do
        it "creates correct inventory" do
          subject.add(variant, 2, shipment: shipment)
          expect(order.inventory_units.count).to eq(2)
        end
      end

      context "called multiple times" do
        it "creates correct inventory" do
          subject.add(variant, 1, shipment: shipment)
          subject.add(variant, 1, shipment: shipment)
          expect(order.inventory_units.count).to eq(2)
        end
      end
    end

    context 'not given a shipment' do
      it "ensures updated shipments" do
        expect(subject.order).to receive(:ensure_updated_shipments)
        subject.add(variant)
      end
    end

    it 'should add line item if one does not exist' do
      line_item = subject.add(variant, 1)
      expect(line_item.quantity).to eq(1)
      expect(order.line_items.size).to eq(1)
    end

    it 'should update line item if one exists' do
      subject.add(variant, 1)
      line_item = subject.add(variant, 1)
      expect(line_item.quantity).to eq(2)
      expect(order.line_items.size).to eq(1)
    end

    it "should update order totals" do
      expect(order.item_total.to_f).to eq(0.00)
      expect(order.total.to_f).to eq(0.00)

      subject.add(variant, 1)

      expect(order.item_total.to_f).to eq(19.99)
      expect(order.total.to_f).to eq(19.99)
    end

    context "running promotions" do
      let(:promotion) { create(:promotion, apply_automatically: true) }
      let(:calculator) { Spree::Calculator::FlatRate.new(preferred_amount: 10) }

      shared_context "discount changes order total" do
        before { subject.add(variant, 1) }
        it { expect(subject.order.total).not_to eq variant.price }
      end

      context "one active order promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateAdjustment.create(promotion: promotion, calculator: calculator) }

        it "creates valid discount on order" do
          subject.add(variant, 1)
          expect(subject.order.adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end

      context "one active line item promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(promotion: promotion, calculator: calculator) }

        it "creates valid discount on order" do
          subject.add(variant, 1)
          expect(subject.order.line_item_adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end
    end

    describe 'tax calculations' do
      let!(:zone) { create(:global_zone) }
      let!(:tax_rate) do
        create(:tax_rate, zone: zone, tax_categories: [variant.tax_category])
      end

      context 'when the order has a taxable address' do
        before do
          expect(order.tax_address.country_id).to be_present
        end

        it 'creates a tax adjustment' do
          order_contents.add(variant)
          line_item = order.find_line_item_by_variant(variant)
          expect(line_item.adjustments.tax.count).to eq(1)
        end
      end

      context 'when the order does not have a taxable address' do
        before do
          order.update!(ship_address: nil, bill_address: nil)
          expect(order.tax_address.country_id).to be_nil
        end

        it 'creates a tax adjustment' do
          order_contents.add(variant)
          line_item = order.find_line_item_by_variant(variant)
          expect(line_item.adjustments.tax.count).to eq(0)
        end
      end
    end
  end

  context "#remove" do
    context "given an invalid variant" do
      it "raises an exception" do
        expect {
          subject.remove(variant, 1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'given quantity is not explicitly provided' do
      it 'should remove one line item' do
        line_item = subject.add(variant, 3)
        subject.remove(variant)

        expect(line_item.reload.quantity).to eq(2)
      end
    end

    context 'given a shipment' do
      it "ensure shipment calls update_amounts instead of order calling ensure_updated_shipments" do
        subject.add(variant, 1)
        shipment = create(:shipment)
        expect(subject.order).to_not receive(:ensure_updated_shipments)
        expect(shipment).to receive(:update_amounts)
        subject.remove(variant, 1, shipment: shipment)
      end
    end

    context 'not given a shipment' do
      it "ensures updated shipments" do
        subject.add(variant, 1)
        expect(subject.order).to receive(:ensure_updated_shipments)
        subject.remove(variant)
      end
    end

    it 'should reduce line_item quantity if quantity is less the line_item quantity' do
      line_item = subject.add(variant, 3)
      subject.remove(variant, 1)

      expect(line_item.reload.quantity).to eq(2)
    end

    it 'should remove line_item if quantity matches line_item quantity' do
      subject.add(variant, 1)
      subject.remove(variant, 1)

      expect(order.reload.find_line_item_by_variant(variant)).to be_nil
    end

    it 'should remove line_item if quantity is greater than line_item quantity' do
      subject.add(variant, 1)
      subject.remove(variant, 2)

      expect(order.reload.find_line_item_by_variant(variant)).to be_nil
    end

    it "should update order totals" do
      expect(order.item_total.to_f).to eq(0.00)
      expect(order.total.to_f).to eq(0.00)

      subject.add(variant, 2)

      expect(order.item_total.to_f).to eq(39.98)
      expect(order.total.to_f).to eq(39.98)

      subject.remove(variant, 1)
      expect(order.item_total.to_f).to eq(19.99)
      expect(order.total.to_f).to eq(19.99)
    end
  end

  context "#remove_line_item" do
    context 'given a shipment' do
      it "ensure shipment calls update_amounts instead of order calling ensure_updated_shipments" do
        line_item = subject.add(variant, 1)
        shipment = create(:shipment)
        expect(subject.order).to_not receive(:ensure_updated_shipments)
        expect(shipment).to receive(:update_amounts)
        subject.remove_line_item(line_item, shipment: shipment)
      end
    end

    context 'not given a shipment' do
      it "ensures updated shipments" do
        line_item = subject.add(variant, 1)
        expect(subject.order).to receive(:ensure_updated_shipments)
        subject.remove_line_item(line_item)
      end
    end

    it 'should remove line_item' do
      line_item = subject.add(variant, 1)
      subject.remove_line_item(line_item)

      expect(order.reload.line_items).to_not include(line_item)
    end

    it "should update order totals" do
      expect(order.item_total.to_f).to eq(0.00)
      expect(order.total.to_f).to eq(0.00)

      line_item = subject.add(variant, 2)

      expect(order.item_total.to_f).to eq(39.98)
      expect(order.total.to_f).to eq(39.98)

      subject.remove_line_item(line_item)
      expect(order.item_total.to_f).to eq(0.00)
      expect(order.total.to_f).to eq(0.00)
    end
  end

  context "update cart" do
    let!(:shirt) { subject.add variant, 1 }

    let(:params) do
      { line_items_attributes: {
        "0" => { id: shirt.id, quantity: 3 }
      } }
    end

    it "changes item quantity" do
      subject.update_cart params
      expect(shirt.reload.quantity).to eq 3
    end

    it "updates order totals" do
      expect {
        subject.update_cart params
      }.to change { subject.order.total }
    end

    context "submits item quantity 0" do
      let(:params) do
        { line_items_attributes: {
          "0" => { id: shirt.id, quantity: 0 }
        } }
      end

      it "removes item from order" do
        expect {
          subject.update_cart params
        }.to change { subject.order.line_items.count }
      end
    end

    it "ensures updated shipments" do
      expect(subject.order).to receive(:ensure_updated_shipments)
      subject.update_cart params
    end
  end

  context "completed order" do
    let(:order) { Spree::Order.create! state: 'complete', completed_at: Time.current }

    before { order.shipments.create! stock_location_id: variant.stock_location_ids.first }

    it "updates order payment state" do
      expect {
        subject.add variant
      }.to change { order.payment_state }

      expect {
        subject.remove variant
      }.to change { order.payment_state }
    end
  end

  describe "#approve" do
    context 'when a name is supplied' do
      it 'approves the order' do
        order.contents.approve(name: 'Jordan')
        expect(order.approver).to be_nil
        expect(order.approver_name).to eq('Jordan')
        expect(order.approved_at).to be_present
        expect(order.approved?).to be_truthy
      end
    end

    context 'when a user is supplied' do
      let(:user) { create(:user) }

      it 'approves the order' do
        order.contents.approve(user: user)
        expect(order.approver).to eq(user)
        expect(order.approver_name).to be_nil
        expect(order.approved_at).to be_present
        expect(order.approved?).to be_truthy
      end
    end

    context 'when a user and a name are supplied' do
      let(:user) { create(:user) }

      it 'approves the order' do
        order.contents.approve(user: user, name: 'Jordan')
        expect(order.approver).to eq(user)
        expect(order.approver_name).to eq('Jordan')
        expect(order.approved_at).to be_present
        expect(order.approved?).to be_truthy
      end
    end

    context 'when neither a user nor a name are supplied' do
      it 'raises' do
        expect {
          order.contents.approve
        }.to raise_error(ArgumentError, 'user or name must be specified')
      end
    end
  end
end
