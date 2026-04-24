# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Promotion::Rules::User, type: :model do
  let(:rule) { Spree::Promotion::Rules::User.new }

  describe "#preload_relations" do
    subject { rule.preload_relations }
    it { is_expected.to eq([]) }
  end

  describe "#migration_relations" do
    subject { rule.migration_relations }
    it { is_expected.to eq([:users]) }
  end

  context "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "should not be eligible if users are not provided" do
      expect(rule).not_to be_eligible(order)
    end

    it "should be eligible if users include user placing the order" do
      user = Spree::LegacyUser.create!(email: "test1@example.com")
      rule.users << user
      allow(order).to receive_messages(user:)

      expect(rule).to be_eligible(order)
    end

    it "should not be eligible if user placing the order is not listed" do
      order_user = Spree::LegacyUser.create!(email: "order_user@example.com")
      other_user1 = Spree::LegacyUser.create!(email: "other1@example.com")
      other_user2 = Spree::LegacyUser.create!(email: "other2@example.com")
      rule.users << [other_user1, other_user2]
      allow(order).to receive_messages(user: order_user)

      expect(rule).not_to be_eligible(order)
    end

    it "should not be eligible if order has no user" do
      allow(order).to receive_messages(user: nil)

      expect(rule).not_to be_eligible(order)
    end

    it "uses a database query instead of loading all users into memory" do
      user = Spree::LegacyUser.create!(email: "test_query@example.com")
      rule.users << user
      allow(order).to receive_messages(user:)

      # eligible? should use exists? which does not load user records
      expect(rule.users).not_to receive(:load)
      expect(rule).to be_eligible(order)
    end

    # Regression test for https://github.com/spree/spree/issues/3885
    it "can assign to user_ids" do
      user1 = Spree::LegacyUser.create!(email: "test1@example.com")
      user2 = Spree::LegacyUser.create!(email: "test2@example.com")
      rule.user_ids = "#{user1.id}, #{user2.id}"
    end
  end
end
