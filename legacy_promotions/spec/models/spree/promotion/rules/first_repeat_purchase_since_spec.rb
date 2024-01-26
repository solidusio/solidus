# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Rules::FirstRepeatPurchaseSince do
  describe "#applicable?" do
    subject { described_class.new.applicable?(promotable) }

    context "when the promotable is an order" do
      let(:promotable) { Spree::Order.new }

      it { is_expected.to be true }
    end

    context "when the promotable is not a order" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe "eligible?" do
    let(:instance) { described_class.new }
    subject { instance.eligible?(order) }

    before do
      instance.preferred_days_ago = 365
    end

    context "when the order does not have a user" do
      let(:order) { Spree::Order.new }

      it { is_expected.to be false }
    end

    context "when the order has a user" do
      let(:order) { create :order }
      let(:user) { order.user }

      context "when the user has completed orders" do
        let(:order_completion_date_1) { 1.day.ago }
        let(:order_completion_date_2) { 1.day.ago }
        before do
          old_order_1 = create :completed_order_with_totals, user: user
          old_order_1.update(completed_at: order_completion_date_1)

          old_order_2 = create :completed_order_with_totals, user: user
          old_order_2.update(completed_at: order_completion_date_2)
        end

        context "the last completed order was greater than the preferred days ago" do
          let(:order_completion_date_1) { 14.months.ago }
          let(:order_completion_date_2) { 13.months.ago }

          it { is_expected.to be true }
        end

        context "the last completed order was less than the preferred days ago" do
          let(:order_completion_date_1) { 14.months.ago }
          let(:order_completion_date_2) { 11.months.ago }

          it { is_expected.to be false }
        end
      end

      context "when the user has no completed orders " do
        it { is_expected.to be false }
      end
    end
  end
end
