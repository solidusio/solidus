# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::Store, type: :model do
  let(:condition) { described_class.new }

  it { is_expected.to have_many(:stores) }

  describe "store_ids=" do
    subject { condition.store_ids = [store.id] }

    let!(:promotion) { create(:friendly_promotion, :with_adjustable_benefit) }
    let(:promotion_benefit) { promotion.benefits.first }
    let!(:unimportant_store) { create(:store) }
    let!(:store) { create(:store) }
    let(:condition) { promotion_benefit.conditions.build(type: described_class.to_s) }

    it "creates a valid condition with a store" do
      subject
      expect(condition).to be_valid
      expect(condition.stores).to include(store)
    end
  end

  describe "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "is eligible if no stores are provided" do
      expect(condition).to be_eligible(order)
    end

    it "is eligible if stores include the order's store" do
      default_store = Spree::Store.new(name: "Default")
      other_store = Spree::Store.new(name: "Other")

      condition.stores = [default_store, other_store]
      order.store = default_store

      expect(condition).to be_eligible(order)
    end

    it "is not eligible if order is placed in a different store" do
      default_store = Spree::Store.new(name: "Default")
      other_store = Spree::Store.new(name: "Other")

      condition.stores = [other_store]
      order.store = default_store

      expect(condition).not_to be_eligible(order)
    end
  end
end
