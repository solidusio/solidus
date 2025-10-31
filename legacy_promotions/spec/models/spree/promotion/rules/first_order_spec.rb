# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Promotion::Rules::FirstOrder, type: :model do
  let(:condition) { described_class.new }
  let(:order) { create(:order, user:, email:) }
  let(:user) { nil }
  let(:email) { nil }

  describe ".to_partial_path" do
    subject { condition.to_partial_path }

    it { is_expected.to eq("spree/admin/promotions/rules/first_order") }
  end

  context "without a user or email" do
    it { expect(condition).to be_eligible(order) }

    it "does not set an error message" do
      condition.eligible?(order)
      expect(condition.eligibility_errors.full_messages.first)
        .to be_nil
    end
  end

  context "first order" do
    context "for a signed user" do
      let(:user) { create(:user) }
      let(:email) { user.email }

      context "with no completed, un-canceled orders" do
        it "is eligible when user passed in payload data" do
          expect(condition).to be_eligible(order, user: user)
        end
      end

      context "with completed orders" do
        let(:order) { create(:completed_order_with_totals, user:, email:) }

        it "is eligible when checked against first completed order" do
          expect(condition).to be_eligible(order)
        end

        context "with another order" do
          let!(:previous_order) { create(:completed_order_with_totals, user:) }

          it { expect(condition).not_to be_eligible(order) }

          context "if previous order is canceled" do
            before do
              previous_order.cancel!
            end

            it { expect(condition).to be_eligible(order) }
          end

          it "sets an error message" do
            condition.eligible?(order)
            expect(condition.eligibility_errors.full_messages.first)
              .to eq "This coupon code can only be applied to your first order."
          end

          it "sets an error code" do
            condition.eligible?(order)
            expect(condition.eligibility_errors.details[:base].first[:error_code])
              .to eq :not_first_order
          end
        end
      end
    end

    context "for a guest user" do
      let(:email) { "user@solidus.io" }

      context "with no other orders" do
        it { expect(condition).to be_eligible(order) }
      end

      context "with another order" do
        let!(:previous_order) { create(:completed_order_with_totals, user: nil, email:) }

        it { expect(condition).not_to be_eligible(order) }

        context "if previous order is canceled" do
          before do
            previous_order.cancel!
          end

          it { expect(condition).to be_eligible(order) }
        end

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first)
            .to eq "This coupon code can only be applied to your first order."
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :not_first_order
        end
      end
    end
  end
end
