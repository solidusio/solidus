# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::DiscountedItemTotal, type: :model do
  let(:condition) do
    described_class.new(
      preferred_amount: preferred_amount,
      preferred_operator: preferred_operator
    )
  end
  let(:order) { Spree::Order.new(currency: order_currency) }
  let(:preferred_amount) { 50 }
  let(:order_currency) { "USD" }
  let(:preferred_operator) { "gt" }
  let(:item_total) { 0 }
  before do
    allow(order).to receive(:discountable_item_total).and_return(item_total)
  end

  context "preferred operator set to gt" do
    context "item total is greater than preferred amount" do
      let(:item_total) { 51 }

      it "is eligible when item total is greater than preferred amount" do
        expect(condition).to be_eligible(order)
      end

      context "when the order is a different currency" do
        let(:order_currency) { "CAD" }

        it "is not eligible" do
          expect(condition).not_to be_eligible(order)
        end
      end
    end

    context "when item total is equal to preferred amount" do
      let(:item_total) { 50 }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end

      it "set an error message" do
        condition.eligible?(order)
        expect(condition.eligibility_errors.full_messages.first)
          .to eq "This coupon code can't be applied to orders less than or equal to $50.00."
      end

      it "sets an error code" do
        condition.eligible?(order)
        expect(condition.eligibility_errors.details[:base].first[:error_code])
          .to eq :item_total_less_than_or_equal
      end
    end

    context "when item total is lower than preferred amount" do
      let(:item_total) { 49 }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end

      it "set an error message" do
        condition.eligible?(order)
        expect(condition.eligibility_errors.full_messages.first)
          .to eq "This coupon code can't be applied to orders less than or equal to $50.00."
      end

      it "sets an error code" do
        condition.eligible?(order)
        expect(condition.eligibility_errors.details[:base].first[:error_code])
          .to eq :item_total_less_than_or_equal
      end
    end
  end

  context "preferred operator set to gte" do
    let(:preferred_operator) { "gte" }

    context "total is greater than preferred amount" do
      let(:item_total) { 51 }

      it "is eligible when item total is greater than preferred amount" do
        expect(condition).to be_eligible(order)
      end

      context "when the order is a different currency" do
        let(:order_currency) { "CAD" }

        it "is not eligible" do
          expect(condition).not_to be_eligible(order)
        end
      end
    end

    context "item total is equal to preferred amount" do
      let(:item_total) { 50 }

      it "is eligible" do
        expect(condition).to be_eligible(order)
      end

      context "when the order is a different currency" do
        let(:order_currency) { "CAD" }

        it "is not eligible" do
          expect(condition).not_to be_eligible(order)
        end
      end
    end

    context "when item total is lower than preferred amount" do
      let(:item_total) { 49 }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end

      it "set an error message" do
        condition.eligible?(order)
        expect(condition.eligibility_errors.full_messages.first)
          .to eq "This coupon code can't be applied to orders less than $50.00."
      end

      it "sets an error code" do
        condition.eligible?(order)
        expect(condition.eligibility_errors.details[:base].first[:error_code])
          .to eq :item_total_less_than
      end
    end
  end

  describe "#to_partial_path" do
    it "uses the item total partial path" do
      expect(condition.to_partial_path).to eq "solidus_promotions/admin/condition_fields/item_total"
    end
  end
end
