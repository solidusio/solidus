# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::Promotion::Rules::User, type: :model do
  let(:rule) { Solidus::Promotion::Rules::User.new }

  context "#eligible?(order)" do
    let(:order) { Solidus::Order.new }

    it "should not be eligible if users are not provided" do
      expect(rule).not_to be_eligible(order)
    end

    it "should be eligible if users include user placing the order" do
      user = mock_model(Solidus::LegacyUser)
      users = [user, mock_model(Solidus::LegacyUser)]
      allow(rule).to receive_messages(users: users)
      allow(order).to receive_messages(user: user)

      expect(rule).to be_eligible(order)
    end

    it "should not be eligible if user placing the order is not listed" do
      allow(order).to receive_messages(user: mock_model(Solidus::LegacyUser))
      users = [mock_model(Solidus::LegacyUser), mock_model(Solidus::LegacyUser)]
      allow(rule).to receive_messages(users: users)

      expect(rule).not_to be_eligible(order)
    end

    # Regression test for https://github.com/spree/spree/issues/3885
    it "can assign to user_ids" do
      user1 = Solidus::LegacyUser.create!(email: "test1@example.com")
      user2 = Solidus::LegacyUser.create!(email: "test2@example.com")
      rule.user_ids = "#{user1.id}, #{user2.id}"
    end
  end
end
