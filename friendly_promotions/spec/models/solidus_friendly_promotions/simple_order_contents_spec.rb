# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::SimpleOrderContents, type: :model do
  subject(:order_contents) { described_class.new(order) }

  let!(:store) { create :store }
  let(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let!(:stock_location) { variant.stock_locations.first }

  describe "#add" do
    context "given quantity is not explicitly provided" do
      it "adds one line item" do
        line_item = subject.add(variant)
        expect(line_item.quantity).to eq(1)
        expect(order.line_items.size).to eq(1)
      end

      context "if a line item managed by an automation exists" do
        let(:promotion) { create(:friendly_promotion, apply_automatically: true) }
        let(:promotion_benefit) { SolidusFriendlyPromotions::Benefits::CreateDiscountedItem.create!(calculator: hundred_percent, preferred_variant_id: variant.id, promotion: promotion) }
        let(:hundred_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 100) }

        before do
          order.line_items.create!(variant: variant, managed_by_order_benefit: promotion_benefit, quantity: 1)
        end

        specify "creating a new line item with the same variant creates a separate item" do
          expect { subject.add(variant) }.to change { order.line_items.length }.by(1)
        end
      end
    end

    context "given a shipment" do
      let!(:shipment) { create(:shipment, order: order) }

      it "ensure shipment calls update_amounts instead of order calling check_shipments_and_restart_checkout" do
        expect(subject.order).not_to receive(:check_shipments_and_restart_checkout)
        expect(shipment).to receive(:update_amounts).at_least(:once)
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

    context "not given a shipment" do
      it "ensures updated shipments" do
        expect(subject.order).to receive(:check_shipments_and_restart_checkout)
        subject.add(variant)
      end
    end

    it "adds line item if one does not exist" do
      line_item = subject.add(variant, 1)
      expect(line_item.quantity).to eq(1)
      expect(order.line_items.size).to eq(1)
    end

    it "updates line item if one exists" do
      subject.add(variant, 1)
      line_item = subject.add(variant, 1)
      expect(line_item.quantity).to eq(2)
      expect(order.line_items.size).to eq(1)
    end

    it "updates order totals" do
      expect(order.item_total.to_f).to eq(0.00)
      expect(order.total.to_f).to eq(0.00)

      subject.add(variant, 1)

      expect(order.item_total.to_f).to eq(19.99)
      expect(order.total.to_f).to eq(19.99)
    end

    context "running promotions" do
      let(:promotion) { create(:friendly_promotion, apply_automatically: true) }
      let(:calculator) { SolidusFriendlyPromotions::Calculators::FlatRate.new(preferred_amount: 10) }

      context "one active line item promotion" do
        let!(:benefit) do
          SolidusFriendlyPromotions::Benefits::AdjustLineItem.create(promotion: promotion, calculator: calculator)
        end

        it "creates valid discount on order" do
          subject.add(variant, 1)
          subject.order.line_item_adjustments.reset
          expect(subject.order.line_item_adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        context "discount changes order total" do
          before { subject.add(variant, 1) }

          it { expect(subject.order.total).not_to eq variant.price }
        end
      end
    end

    describe "tax calculations" do
      let!(:zone) { create(:global_zone) }
      let!(:tax_rate) do
        create(:tax_rate, zone: zone, tax_categories: [variant.tax_category])
      end

      context "when the order has a taxable address" do
        it "creates a tax adjustment" do
          expect(order.tax_address.country_id).to be_present
          order_contents.add(variant)
          line_item = order.find_line_item_by_variant(variant)
          expect(line_item.adjustments.tax.count).to eq(1)
        end
      end

      context "when the order does not have a taxable address" do
        before do
          order.update!(ship_address: nil, bill_address: nil)
        end

        it "creates a tax adjustment" do
          expect(order.tax_address.country_id).to be_nil
          order_contents.add(variant)
          line_item = order.find_line_item_by_variant(variant)
          expect(line_item.adjustments.tax.count).to eq(0)
        end
      end
    end
  end

  describe "#remove" do
    context "given an invalid variant" do
      it "raises an exception" do
        expect {
          subject.remove(variant, 1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "given quantity is not explicitly provided" do
      it "removes one line item" do
        line_item = subject.add(variant, 3)
        subject.remove(variant)

        expect(line_item.reload.quantity).to eq(2)
      end
    end

    context "given a shipment" do
      it "ensure shipment calls update_amounts instead of order calling check_shipments_and_restart_checkout" do
        subject.add(variant, 1)
        shipment = create(:shipment)
        expect(subject.order).not_to receive(:check_shipments_and_restart_checkout)
        expect(shipment).to receive(:update_amounts)
        subject.remove(variant, 1, shipment: shipment)
      end
    end

    context "not given a shipment" do
      it "ensures updated shipments" do
        subject.add(variant, 1)
        expect(subject.order).to receive(:check_shipments_and_restart_checkout)
        subject.remove(variant)
      end
    end

    it "reduces line_item quantity if quantity is less the line_item quantity" do
      line_item = subject.add(variant, 3)
      subject.remove(variant, 1)

      expect(line_item.reload.quantity).to eq(2)
    end

    it "removes line_item if quantity matches line_item quantity" do
      subject.add(variant, 1)
      subject.remove(variant, 1)

      expect(order.reload.find_line_item_by_variant(variant)).to be_nil
    end

    it "removes line_item if quantity is greater than line_item quantity" do
      subject.add(variant, 1)
      subject.remove(variant, 2)

      expect(order.reload.find_line_item_by_variant(variant)).to be_nil
    end

    it "updates order totals" do
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

  describe "#remove_line_item" do
    context "given a shipment" do
      it "ensure shipment calls update_amounts instead of order calling check_shipments_and_restart_checkout" do
        line_item = subject.add(variant, 1)
        shipment = create(:shipment)
        expect(subject.order).not_to receive(:check_shipments_and_restart_checkout)
        expect(shipment).to receive(:update_amounts)
        subject.remove_line_item(line_item, shipment: shipment)
      end
    end

    context "not given a shipment" do
      it "ensures updated shipments" do
        line_item = subject.add(variant, 1)
        expect(subject.order).to receive(:check_shipments_and_restart_checkout)
        subject.remove_line_item(line_item)
      end
    end

    it "removes line_item" do
      line_item = subject.add(variant, 1)
      subject.remove_line_item(line_item)

      expect(order.reload.line_items).not_to include(line_item)
    end

    it "updates order totals" do
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
      {line_items_attributes: {
        "0" => {id: shirt.id, quantity: 3}
      }}
    end

    it "changes item quantity" do
      subject.update_cart params
      expect(shirt.reload.quantity).to eq 3
    end

    it "updates order totals" do
      expect {
        subject.update_cart params
      }.to(change { subject.order.total })
    end

    context "submits item quantity 0" do
      let(:params) do
        {line_items_attributes: {
          "0" => {id: shirt.id, quantity: 0}
        }}
      end

      it "removes item from order" do
        expect {
          subject.update_cart params
        }.to(change { subject.order.line_items.count })
      end
    end

    it "ensures updated shipments" do
      expect(subject.order).to receive(:check_shipments_and_restart_checkout)
      subject.update_cart params
    end
  end

  context "completed order" do
    let(:order) do
      Spree::Order.create!(
        state: "complete",
        completed_at: Time.current,
        email: "test@example.com"
      )
    end

    before { order.shipments.create! stock_location_id: variant.stock_location_ids.first }

    it "updates order payment state" do
      expect {
        subject.add variant
      }.to(change(order, :payment_state))

      expect {
        subject.remove variant
      }.to(change(order, :payment_state))
    end
  end

  describe "#approve" do
    context "when a name is supplied" do
      it "approves the order" do
        order.contents.approve(name: "Jordan")
        expect(order.approver).to be_nil
        expect(order.approver_name).to eq("Jordan")
        expect(order.approved_at).to be_present
        expect(order).to be_approved
      end
    end

    context "when a user is supplied" do
      let(:user) { create(:user) }

      it "approves the order" do
        order.contents.approve(user: user)
        expect(order.approver).to eq(user)
        expect(order.approver_name).to be_nil
        expect(order.approved_at).to be_present
        expect(order).to be_approved
      end
    end

    context "when a user and a name are supplied" do
      let(:user) { create(:user) }

      it "approves the order" do
        order.contents.approve(user: user, name: "Jordan")
        expect(order.approver).to eq(user)
        expect(order.approver_name).to eq("Jordan")
        expect(order.approved_at).to be_present
        expect(order).to be_approved
      end
    end

    context "when neither a user nor a name are supplied" do
      it "raises" do
        expect {
          order.contents.approve
        }.to raise_error(ArgumentError, "user or name must be specified")
      end
    end
  end
end
