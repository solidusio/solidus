# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::CustomerReturn, type: :model do
  before do
    allow_any_instance_of(Spree::Order).to receive_messages(return!: true)
  end

  describe "#valid?" do
    subject { customer_return.valid? }

    let(:customer_return) { build(:customer_return) }

    let(:first_order) { create(:order_with_line_items) }
    let(:second_order) { first_order }

    let(:first_shipment) { first_order.shipments.first }
    let(:second_shipment) { second_order.shipments.first }

    let(:first_inventory_unit) { build(:inventory_unit, shipment: first_shipment, state: "shipped") }
    let(:first_return_item) { build(:return_item, inventory_unit: first_inventory_unit) }

    let(:second_inventory_unit) { build(:inventory_unit, shipment: second_shipment, state: "shipped") }
    let(:second_return_item) { build(:return_item, inventory_unit: second_inventory_unit) }

    before do
      customer_return.return_items << first_return_item
      customer_return.return_items << second_return_item
    end

    context "when the return items belong to the same order" do
      let(:second_order) { first_order }

      it "is valid" do
        expect(subject).to eq true
      end
    end

    context "when the return items belong to different orders" do
      let(:second_order) { create(:order_with_line_items) }

      it "is not valid" do
        expect(subject).to eq false
      end

      it "adds an error message" do
        subject
        expect(customer_return.errors.full_messages).to include(I18n.t("spree.return_items_cannot_be_associated_with_multiple_orders"))
      end
    end

    context "when a return item's inventory unit has not shipped" do
      let(:first_inventory_unit) { build(:inventory_unit, shipment: first_shipment, state: "on_hand") }

      it "is not valid" do
        expect(subject).to eq false
      end

      it "adds an error message" do
        subject

        expect(customer_return.errors.full_messages)
          .to include(I18n.t("spree.return_items_must_have_shipped_inventory_units"))
      end
    end

    context "when a return item is being received against an unshipped unit" do
      let(:first_inventory_unit) { build(:inventory_unit, shipment: first_shipment, state: "on_hand") }
      let(:first_return_item) do
        build(:return_item, inventory_unit: first_inventory_unit, reception_status_event: "receive")
      end

      it "is not valid" do
        expect(subject).to eq false
      end
    end

    context "when a return item has already been received" do
      let(:customer_return) { create(:customer_return, return_items_count: 1) }

      before { customer_return.return_items.first.receive! }

      it "is still valid once its inventory unit has been returned" do
        expect(customer_return.reload).to be_valid
      end
    end

    context "when inventory is not present" do
      before do
        customer_return.return_items.clear

        customer_return.return_items << Spree::ReturnItem.new
      end

      it "is invalid" do
        expect(subject).to eq false
      end
    end
  end

  describe "#save" do
    subject { customer_return.save }

    let(:order) { create(:shipped_order, line_items_count: 1) }
    let(:inventory_unit) { order.inventory_units.first }
    let(:customer_return) do
      build(:customer_return_without_return_items).tap do |record|
        record.return_items = [
          build(:return_item, inventory_unit:, reception_status_event: "receive")
        ]
      end
    end

    context "when the inventory unit has not shipped" do
      before { inventory_unit.update_column(:state, "on_hand") }

      it "is rejected rather than raising an invalid transition" do
        expect(subject).to eq false
      end
    end

    context "when the inventory unit has shipped" do
      it { is_expected.to eq true }
    end
  end

  describe ".before_create" do
    describe "#generate_number" do
      context "number is assigned" do
        let(:customer_return) { Spree::CustomerReturn.new(number: "123") }

        it "should return the assigned number" do
          customer_return.save
          expect(customer_return.number).to eq("123")
        end
      end

      context "number is not assigned" do
        let(:customer_return) { Spree::CustomerReturn.new(number: nil) }

        before do
          allow(customer_return).to receive_messages(valid?: true, process_return!: true)
        end

        it "should assign number with random CR number" do
          customer_return.save
          expect(customer_return.number).to match(/CR\d{9}/)
        end
      end
    end
  end

  describe "#total" do
    let(:amount) { 15.0 }
    let(:tax_amount) { 5.0 }
    let(:customer_return) { create(:customer_return, line_items_count: 2) }

    before do
      Spree::ReturnItem.where(customer_return_id: customer_return.id).update_all(amount:, additional_tax_total: tax_amount)
      customer_return.reload
    end

    subject { customer_return.total }

    it "returns the sum of the return item's total amount" do
      expect(subject).to eq((amount * 2) + (tax_amount * 2))
    end
  end

  describe "#display_total" do
    let(:customer_return) { stub_model(Spree::CustomerReturn, total: 21.22, currency: "GBP") }

    it "returns a Spree::Money" do
      expect(customer_return.display_total).to eq(Spree::Money.new(21.22, currency: "GBP"))
    end
  end

  describe "#currency" do
    let(:order) { stub_model(Spree::Order, currency: "GBP") }
    let(:customer_return) { stub_model(Spree::CustomerReturn, order:) }

    it "returns the order currency" do
      expect(Spree::Config.currency).to eq("USD")
      expect(customer_return.currency).to eq("GBP")
    end
  end

  describe "#amount" do
    let(:amount) { 15.0 }
    let(:customer_return) { create(:customer_return, line_items_count: 2) }

    before do
      Spree::ReturnItem.where(customer_return_id: customer_return.id).update_all(amount:)
    end

    subject { customer_return.amount }

    it "returns the sum of the return item's amount" do
      expect(subject).to eq(amount * 2)
    end
  end

  describe "#display_amount" do
    let(:customer_return) { stub_model(Spree::CustomerReturn, amount: 21.22, currency: "RUB") }

    it "returns a Spree::Money" do
      expect(customer_return.display_amount).to eq(Spree::Money.new(21.22, currency: "RUB"))
    end
  end

  describe "#order" do
    let(:return_item) { create(:return_item) }
    let(:customer_return) { build(:customer_return, return_items: [return_item]) }

    subject { customer_return.order }

    it "returns the order associated with the return item's inventory unit" do
      expect(subject).to eq return_item.inventory_unit.order
    end
  end

  describe "#order_id" do
    subject { customer_return.order_id }

    context "return item is not associated yet" do
      let(:customer_return) { build(:customer_return) }

      it "is nil" do
        expect(subject).to be_nil
      end
    end

    context "has an associated return item" do
      let(:return_item) { create(:return_item) }
      let(:customer_return) { build(:customer_return, return_items: [return_item]) }

      it "is the return item's inventory unit's order id" do
        expect(subject).to eq return_item.inventory_unit.order.id
      end
    end
  end

  context ".after_save" do
    let(:inventory_unit) { create(:inventory_unit, state: "shipped", order: create(:shipped_order)) }
    let(:return_item) { build(:return_item, inventory_unit:) }

    context "to the initial stock location" do
      it "should mark the received inventory units are returned" do
        create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: inventory_unit.shipment.stock_location_id)
        return_item.receive!
        expect(inventory_unit.reload.state).to eq "returned"
      end

      it "should update the stock item counts in the stock location" do
        expect do
          create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: inventory_unit.shipment.stock_location_id)
          return_item.receive!
        end.to change { inventory_unit.find_stock_item.count_on_hand }.by(1)
      end

      context "with Config.track_inventory_levels == false" do
        before do
          stub_spree_preferences(track_inventory_levels: false)
          expect(Spree::StockItem).not_to receive(:find_by)
          expect(Spree::StockMovement).not_to receive(:create!)
        end

        it "should NOT update the stock item counts in the stock location" do
          count_on_hand = inventory_unit.find_stock_item.count_on_hand
          create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: inventory_unit.shipment.stock_location_id)
          expect(inventory_unit.find_stock_item.count_on_hand).to eql count_on_hand
        end
      end
    end

    context "to a different stock location" do
      let(:new_stock_location) { create(:stock_location, name: "other") }

      it "should update the stock item counts in new stock location" do
        expect {
          create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: new_stock_location.id)
          return_item.receive!
        }.to change {
          Spree::StockItem.where(variant_id: inventory_unit.variant_id, stock_location_id: new_stock_location.id).first.count_on_hand
        }.by(1)
      end

      it "should NOT raise an error when no stock item exists in the stock location" do
        inventory_unit.find_stock_item.destroy
        create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: new_stock_location.id)
      end

      it "should NOT raise an error when a soft-deleted stock item exists in the stock location" do
        inventory_unit.find_stock_item.discard
        create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: new_stock_location.id)
      end

      it "should not update the stock item counts in the original stock location" do
        count_on_hand = inventory_unit.find_stock_item.count_on_hand
        create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: new_stock_location.id)
        expect(inventory_unit.find_stock_item.count_on_hand).to eq(count_on_hand)
      end
    end

    context "it was not received" do
      before do
        return_item.update!(reception_status: "lost_in_transit")
      end

      it "should not updated inventory unit to returned" do
        create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: inventory_unit.shipment.stock_location_id)
        expect(inventory_unit.reload.state).to eq "shipped"
      end

      it "should not update the stock item counts in the stock location" do
        expect do
          create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: inventory_unit.shipment.stock_location_id)
        end.to_not change { inventory_unit.find_stock_item.count_on_hand }
      end
    end
  end

  describe "#fully_reimbursed?" do
    let(:customer_return) { create(:customer_return) }

    let!(:default_refund_reason) { Spree::RefundReason.find_or_create_by!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false) }

    subject { customer_return.fully_reimbursed? }

    context "when some return items are undecided" do
      it { is_expected.to be false }
    end

    context "when all return items are decided" do
      context "when all return items are rejected" do
        before { customer_return.return_items.each(&:reject!) }

        it { is_expected.to be true }
      end

      context "when all return items are accepted" do
        before { customer_return.return_items.each(&:accept!) }

        context "when some return items have no reimbursement" do
          it { is_expected.to be false }
        end

        context "when all return items have a reimbursement" do
          let!(:reimbursement) { create(:reimbursement, customer_return:) }

          context "when some reimbursements are not reimbursed" do
            it { is_expected.to be false }
          end

          context "when all reimbursements are reimbursed" do
            let(:created_by_user) { create(:user, email: "user@email.com") }
            before { reimbursement.perform!(created_by: created_by_user) }

            it { is_expected.to be true }
          end
        end
      end
    end
  end

  it_behaves_like "customer and admin metadata fields: storage and validation", :customer_return
end
