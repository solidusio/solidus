# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Reimbursement, type: :model do
  describe ".create" do
    let(:customer_return) { create(:customer_return) }
    let(:order) { customer_return.order }
    let(:reimbursement) { build(:reimbursement, order:) }

    subject { reimbursement.save }

    context "when total is not present" do
      before do
        allow(reimbursement).to receive(:calculated_total) { 100 }
      end

      it { expect { subject }.to change(reimbursement, :total).from(nil).to(100.0) }
    end

    context "when total is present" do
      let(:reimbursement) { build(:reimbursement, order:, total: 10) }

      it { expect { subject }.not_to change(reimbursement, :total).from(10) }
    end
  end

  describe ".before_create" do
    describe "#generate_number" do
      context "number is assigned" do
        let(:number) { "123" }
        let(:reimbursement) { Spree::Reimbursement.new(number:) }

        it "should return the assigned number" do
          reimbursement.save
          expect(reimbursement.number).to eq number
        end
      end

      context "number is not assigned" do
        let(:reimbursement) { Spree::Reimbursement.new(number: nil) }

        before do
          allow(reimbursement).to receive_messages(valid?: true)
        end

        it "should assign number with random RI number" do
          reimbursement.save
          expect(reimbursement.number).to be =~ /RI\d{9}/
        end
      end
    end
  end

  describe "#display_total" do
    let(:total) { 100.50 }
    let(:currency) { "USD" }
    let(:order) { Spree::Order.new(currency:) }
    let(:reimbursement) { Spree::Reimbursement.new(total:, order:) }

    subject { reimbursement.display_total }

    it "returns the value as a Spree::Money instance" do
      expect(subject).to eq Spree::Money.new(total)
    end

    it "uses the order's currency" do
      expect(subject.money.currency.to_s).to eq currency
    end
  end

  describe "#perform!" do
    let!(:adjustments) { [] } # placeholder to ensure it gets run prior the "before" at this level

    let!(:tax_rate) { nil }
    let!(:tax_zone) { create :zone, :with_country }
    let(:shipping_method) { create :shipping_method, zones: [tax_zone] }
    let(:variant) { create :variant }
    let(:order) { create(:order_with_line_items, state: "payment", line_items_attributes: [{variant:, price: line_items_price}], shipment_cost: 0, shipping_method:) }
    let(:line_items_price) { BigDecimal(10) }
    let(:line_item) { order.line_items.first }
    let(:inventory_unit) { line_item.inventory_units.first }
    let(:payment) { build(:payment, amount: payment_amount, order:, state: "checkout") }
    let(:payment_amount) { order.total }
    let(:customer_return) { build(:customer_return, return_items: [return_item]) }
    let(:return_item) { build(:return_item, inventory_unit:) }

    let!(:default_refund_reason) { Spree::RefundReason.find_or_create_by!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false) }

    let(:reimbursement) { create(:reimbursement, customer_return:, order:, return_items: [return_item]) }
    let(:created_by_user) { create(:user, email: "user@email.com") }

    subject { reimbursement.perform!(created_by: created_by_user) }

    before do
      order.shipments.each do |shipment|
        shipment.inventory_units.update_all state: "shipped"
        shipment.update_column("state", "shipped")
      end
      order.reload
      order.recalculate
      if payment
        payment.save!
        order.next! # confirm
      end
      order.complete! # completed
      payment.capture!
      customer_return.save!
      return_item.accept!
    end

    it "refunds the total amount" do
      subject
      expect(reimbursement.unpaid_amount).to eq 0
    end

    it "creates a refund" do
      expect {
        subject
      }.to change { Spree::Refund.count }.by(1)
      expect(Spree::Refund.last.amount).to eq order.total
    end

    context "with additional tax" do
      let!(:tax_rate) { create(:tax_rate, name: "Sales Tax", amount: 0.10, included_in_price: false, zone: tax_zone) }

      it "saves the additional tax and refunds the total" do
        expect {
          subject
        }.to change { Spree::Refund.count }.by(1)
        return_item.reload
        expect(return_item.additional_tax_total).to be > 0
        expect(return_item.additional_tax_total).to eq line_item.additional_tax_total
        expect(reimbursement.total).to eq line_item.amount + line_item.additional_tax_total
        expect(Spree::Refund.last.amount).to eq line_item.amount + line_item.additional_tax_total
      end
    end

    context "with included tax" do
      let!(:tax_rate) { create(:tax_rate, name: "VAT Tax", amount: 0.1, included_in_price: true, zone: tax_zone) }

      it "saves the included tax and refunds the total" do
        expect {
          subject
        }.to change { Spree::Refund.count }.by(1)
        return_item.reload
        expect(return_item.included_tax_total).to be > 0
        expect(return_item.included_tax_total).to eq line_item.included_tax_total
        expect(reimbursement.total).to eq((line_item.total_excluding_vat + line_item.included_tax_total).round(2, :down))
        expect(Spree::Refund.last.amount).to eq((line_item.total_excluding_vat + line_item.included_tax_total).round(2, :down))
      end
    end

    context "when reimbursement cannot be fully performed" do
      let!(:non_return_refund) { create(:refund, amount: 1, payment:) }

      it "does not send a reimbursement email and raises IncompleteReimbursement error" do
        expect(Spree::ReimbursementMailer).not_to receive(:reimbursement_email)
        expect { subject }.to raise_error(Spree::Reimbursement::IncompleteReimbursementError)
      end
    end

    context "when exchange is required" do
      let(:exchange_variant) { create(:on_demand_variant, product: return_item.inventory_unit.variant.product) }
      before { return_item.exchange_variant = exchange_variant }
      it "generates an exchange shipment for the order for the exchange items" do
        expect { subject }.to change { order.reload.shipments.count }.by 1
        expect(order.shipments.last.inventory_units.first.variant).to eq exchange_variant
      end
    end

    it "triggers the reimbursement mailer to be sent via subscribed event" do
      expect(Spree::ReimbursementMailer).to receive(:reimbursement_email).with(reimbursement.id) { double(deliver_later: true) }
      subject
    end
  end

  describe "#return_items_requiring_exchange" do
    it "returns only the return items that require an exchange" do
      return_items = [double(exchange_required?: true), double(exchange_required?: true), double(exchange_required?: false)]
      allow(subject).to receive(:return_items) { return_items }
      expect(subject.return_items_requiring_exchange).to eq return_items.take(2)
    end
  end

  describe "#all_exchanges?" do
    it "returns true if all of the return items processed an exchange" do
      return_items = [double(exchange_processed?: true), double(exchange_processed?: true)]
      allow(subject).to receive(:return_items) { return_items }
      expect(subject.all_exchanges?).to be true
    end

    it "returns false if any of the return items processed an exchange" do
      return_items = [double(exchange_processed?: true), double(exchange_processed?: false)]
      allow(subject).to receive(:return_items) { return_items }
      expect(subject.all_exchanges?).to be false
    end
  end

  describe "#any_exchanges?" do
    it "returns true if any of the return items processed an exchange" do
      return_items = [double(exchange_processed?: true), double(exchange_processed?: false)]
      allow(subject).to receive(:return_items) { return_items }
      expect(subject.any_exchanges?).to be true
    end

    it "returns false if none of the return items processed an exchange" do
      return_items = [double(exchange_processed?: false), double(exchange_processed?: false)]
      allow(subject).to receive(:return_items) { return_items }
      expect(subject.any_exchanges?).to be false
    end
  end

  describe "#calculated_total" do
    context "with return item amounts that would round up" do
      let(:reimbursement) { Spree::Reimbursement.new }

      subject { reimbursement.calculated_total }

      before do
        reimbursement.return_items << Spree::ReturnItem.new(amount: 10.003)
        reimbursement.return_items << Spree::ReturnItem.new(amount: 10.003)
      end

      it "rounds down" do
        expect(subject).to eq 20
      end
    end
  end

  describe ".build_from_customer_return" do
    let(:customer_return) { create(:customer_return, line_items_count: 5) }
    before { customer_return.return_items.each(&:receive!) }
    let!(:pending_return_item) { customer_return.return_items.first.tap { |ri| ri.update!(acceptance_status: "pending") } }
    let!(:accepted_return_item) { customer_return.return_items.second.tap(&:accept!) }
    let!(:rejected_return_item) { customer_return.return_items.third.tap(&:reject!) }
    let!(:manual_intervention_return_item) { customer_return.return_items.fourth.tap(&:require_manual_intervention!) }
    let!(:already_reimbursed_return_item) { customer_return.return_items.fifth }
    let!(:previous_reimbursement) { create(:reimbursement, order: customer_return.order, return_items: [already_reimbursed_return_item]) }

    subject { Spree::Reimbursement.build_from_customer_return(customer_return) }

    it "connects to the accepted return items" do
      expect(subject.return_items.to_a).to eq [accepted_return_item]
    end

    it "connects to the order" do
      expect(subject.order).to eq customer_return.order
    end

    it "connects to the customer_return" do
      expect(subject.customer_return).to eq customer_return
    end
  end

  describe "#return_all" do
    subject { reimbursement.return_all(created_by: created_by_user) }

    let!(:default_refund_reason) { Spree::RefundReason.find_or_create_by!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false) }
    let(:order) { create(:shipped_order, line_items_count: 1) }
    let(:inventory_unit) { order.inventory_units.first }
    let(:return_item) { build(:return_item, inventory_unit:) }
    let(:reimbursement) { build(:reimbursement, order:, return_items: [return_item]) }
    let(:created_by_user) { create(:user, email: "user@email.com") }

    it "accepts all the return items" do
      expect { subject }.to change { return_item.acceptance_status }.to "accepted"
    end

    it "persists the reimbursement" do
      expect { subject }.to change { reimbursement.persisted? }.to true
    end

    it "performs a reimbursment" do
      expect { subject }.to change { reimbursement.refunds.count }.by(1)
    end
  end

  describe "#store_credit_category" do
    let(:reimbursement) { create(:reimbursement) }

    before do
      create(:store_credit_category, name: "foo")
      create(:store_credit_category, :reimbursement)
    end

    it "fetches the the default reimbursement store category" do
      expect(reimbursement.store_credit_category.name).to eq("Reimbursement")
    end
  end
end
