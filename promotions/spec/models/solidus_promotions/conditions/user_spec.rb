# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::User, type: :model do
  let(:condition) { described_class.new }

  it { is_expected.to have_many(:users) }

  it { is_expected.to be_updateable }

  describe "user_ids=" do
    subject { condition.user_ids = [user.id] }

    let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
    let(:benefit) { promotion.benefits.first }
    let(:user) { create(:user) }
    let(:condition) { described_class.new(users: [user], benefit: benefit) }

    it "creates a valid condition with a user" do
      expect(condition).to be_valid
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([]) }
  end

  describe "#migration_relations" do
    subject { condition.migration_relations }
    it { is_expected.to eq([:users]) }
  end

  describe "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "is not eligible if users are not provided" do
      expect(condition).not_to be_eligible(order)
    end

    it "is eligible if users include user placing the order" do
      user = Spree::LegacyUser.create!(email: "test1@example.com")
      condition.users << user
      allow(order).to receive_messages(user: user)

      expect(condition).to be_eligible(order)
    end

    it "is not eligible if user placing the order is not listed" do
      order_user = Spree::LegacyUser.create!(email: "order_user@example.com")
      other_user1 = Spree::LegacyUser.create!(email: "other1@example.com")
      other_user2 = Spree::LegacyUser.create!(email: "other2@example.com")
      condition.users << [other_user1, other_user2]
      allow(order).to receive_messages(user: order_user)

      expect(condition).not_to be_eligible(order)
    end

    it "is not eligible if order has no user" do
      allow(order).to receive_messages(user: nil)

      expect(condition).not_to be_eligible(order)
    end

    it "uses a database query instead of loading all users into memory" do
      user = Spree::LegacyUser.create!(email: "test_query@example.com")
      condition.users << user
      allow(order).to receive_messages(user: user)

      # eligible? should use exists? which does not load user records
      expect(condition.users).not_to receive(:load)
      expect(condition).to be_eligible(order)
    end

    # Regression test for https://github.com/spree/spree/issues/3885
    it "can assign to user_ids" do
      user1 = Spree::LegacyUser.create!(email: "test1@example.com")
      user2 = Spree::LegacyUser.create!(email: "test2@example.com")
      condition.user_ids = "#{user1.id}, #{user2.id}"
    end
  end
end
