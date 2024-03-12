# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Rules::ItemTotal, type: :model do
  let(:rule) do
    Spree::Promotion::Rules::ItemTotal.new(
      preferred_amount: preferred_amount,
      preferred_operator: preferred_operator
    )
  end
  let(:order) { double(:order, item_total: item_total, currency: order_currency) }
  let(:preferred_amount) { 50 }
  let(:order_currency) { 'USD' }

  context "preferred operator set to gt" do
    let(:preferred_operator) { 'gt' }

    context "item total is greater than preferred amount" do
      let(:item_total) { 51 }

      it "should be eligible when item total is greater than preferred amount" do
        expect(rule).to be_eligible(order)
      end

      context "when the order is a different currency" do
        let(:order_currency) { "CAD" }

        it "is not eligible" do
          expect(rule).not_to be_eligible(order)
        end
      end
    end

    context "when item total is equal to preferred amount" do
      let(:item_total) { 50 }

      it "is not eligible" do
        expect(rule).not_to be_eligible(order)
      end

      it "set an error message" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first).
          to eq "This coupon code can't be applied to orders less than or equal to $50.00."
      end
      it "sets an error code" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.details[:base].first[:error_code]).
          to eq :item_total_less_than_or_equal
      end
    end

    context "when item total is lower than preferred amount" do
      let(:item_total) { 49 }

      it "is not eligible" do
        expect(rule).not_to be_eligible(order)
      end

      it "set an error message" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first).
          to eq "This coupon code can't be applied to orders less than or equal to $50.00."
      end
      it "sets an error code" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.details[:base].first[:error_code]).
          to eq :item_total_less_than_or_equal
      end
    end
  end

  context "preferred operator set to gte" do
    let(:preferred_operator) { 'gte' }

    context "total is greater than preferred amount" do
      let(:item_total) { 51 }

      it "should be eligible when item total is greater than preferred amount" do
        expect(rule).to be_eligible(order)
      end

      context "when the order is a different currency" do
        let(:order_currency) { "CAD" }

        it "is not eligible" do
          expect(rule).not_to be_eligible(order)
        end
      end
    end

    context "item total is equal to preferred amount" do
      let(:item_total) { 50 }

      it "should be eligible" do
        expect(rule).to be_eligible(order)
      end

      context "when the order is a different currency" do
        let(:order_currency) { "CAD" }

        it "is not eligible" do
          expect(rule).not_to be_eligible(order)
        end
      end
    end

    context "when item total is lower than preferred amount" do
      let(:item_total) { 49 }

      it "is not eligible" do
        expect(rule).not_to be_eligible(order)
      end

      it "set an error message" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first).
          to eq "This coupon code can't be applied to orders less than $50.00."
      end
      it "sets an error code" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.details[:base].first[:error_code]).
          to eq :item_total_less_than
      end
    end
  end
end
