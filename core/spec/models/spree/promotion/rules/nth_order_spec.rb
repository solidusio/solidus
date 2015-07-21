require 'spec_helper'

describe Spree::Promotion::Rules::NthOrder do
  describe "#applicable?" do
    subject { described_class.new.applicable?(promotable) }

    context "when the promotable is an order" do
      let(:promotable) { Spree::Order.new }

      it { should be true }
    end

    context "when the promotable is not a order" do
      let(:promotable) { "not an order" }

      it { should be false }
    end
  end

  describe "eligible?" do
    let(:instance) { described_class.new }
    subject { instance.eligible?(order) }

    before do
      instance.preferred_nth_order = 2
    end

    context "when the order does not have a user" do
      let(:order) { Spree::Order.new }

      it { should be false }
    end

    context "when the order has a user" do
      let(:order) { create :order }
      let(:user) { order.user }

      context "when the user has completed orders" do
        before do
          old_order = create :completed_order_with_totals, user: user
          old_order.update_attributes(completed_at: 1.day.ago)
        end

        context "when this order will be the 'nth' order" do
          it { should be true }
        end

        context "when this order is completed and is still the 'nth' order" do
          before do
            order.update_attributes(completed_at: Time.now)
          end

          it { should be true }
        end

        context "when this order will not be the 'nth' order" do
          before do
            instance.preferred_nth_order = 100
          end

          it { should be false }
        end
      end

      context "when the user has no completed orders " do
        it { should be false }
      end
    end
  end
end
