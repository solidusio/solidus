# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Conditions::FirstOrder, type: :model do
  let(:condition) { described_class.new }
  let(:order) { mock_model(Spree::Order, user: nil, email: nil) }
  let(:user) { mock_model(Spree::LegacyUser) }

  describe ".to_partial_path" do
    subject { condition.to_partial_path }

    it { is_expected.to eq("solidus_friendly_promotions/admin/condition_fields/first_order") }
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
      context "with no completed orders" do
        before do
          allow(user).to receive_message_chain(:orders, complete: [])
        end

        specify do
          allow(order).to receive_messages(user: user)
          expect(condition).to be_eligible(order)
        end

        it "is eligible when user passed in payload data" do
          expect(condition).to be_eligible(order, user: user)
        end
      end

      context "with completed orders" do
        before do
          allow(order).to receive_messages(user: user)
        end

        it "is eligible when checked against first completed order" do
          allow(user).to receive_message_chain(:orders, complete: [order])
          expect(condition).to be_eligible(order)
        end

        context "with another order" do
          before { allow(user).to receive_message_chain(:orders, complete: [mock_model(Spree::Order)]) }

          it { expect(condition).not_to be_eligible(order) }

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

      before { allow(order).to receive_messages email: "user@solidus.io" }

      context "with no other orders" do
        it { expect(condition).to be_eligible(order) }
      end

      context "with another order" do
        before { allow(condition).to receive_messages(orders_by_email: [mock_model(Spree::Order)]) }

        it { expect(condition).not_to be_eligible(order) }

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
