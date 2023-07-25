# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::UserLoggedIn, type: :model do
  let(:rule) { described_class.new }

  describe "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "is eligible if order has an associated user" do
      user = Spree::LegacyUser.new
      allow(order).to receive_messages(user: user)

      expect(rule).to be_eligible(order)
    end

    context "when user is not logged in" do
      before { allow(order).to receive_messages(user: nil) } # better to be explicit here

      it { expect(rule).not_to be_eligible(order) }

      it "sets an error message" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first)
          .to eq "You need to login before applying this coupon code."
      end

      it "sets an error code" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.details[:base].first[:error_code])
          .to eq :no_user_specified
      end
    end
  end
end
