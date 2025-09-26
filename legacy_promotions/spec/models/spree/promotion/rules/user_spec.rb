# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Promotion::Rules::User, type: :model do
  let(:rule) { Spree::Promotion::Rules::User.new }

  context "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "should not be eligible if users are not provided" do
      expect(rule).not_to be_eligible(order)
    end

    it "should be eligible if users include user placing the order" do
      user = mock_model(Spree::LegacyUser)
      users = [user, mock_model(Spree::LegacyUser)]
      allow(rule).to receive_messages(users:)
      allow(order).to receive_messages(user:)

      expect(rule).to be_eligible(order)
    end

    it "should not be eligible if user placing the order is not listed" do
      allow(order).to receive_messages(user: mock_model(Spree::LegacyUser))
      users = [mock_model(Spree::LegacyUser), mock_model(Spree::LegacyUser)]
      allow(rule).to receive_messages(users:)

      expect(rule).not_to be_eligible(order)
    end

    # Regression test for https://github.com/spree/spree/issues/3885
    it "can assign to user_ids" do
      user1 = Spree::LegacyUser.create!(email: "test1@example.com")
      user2 = Spree::LegacyUser.create!(email: "test2@example.com")
      rule.user_ids = "#{user1.id}, #{user2.id}"
    end
  end
end
