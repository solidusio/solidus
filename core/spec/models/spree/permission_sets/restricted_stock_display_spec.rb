# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PermissionSets::RestrictedStockDisplay do
  let(:ability) { Spree::Ability.new(user) }
  let(:user) { create :user }

  subject { ability }

  let!(:variant) { create :variant }

  let(:sl1) { create :stock_location, active: false }
  let(:sl2) { create :stock_location, active: false }

  let(:item1) { variant.stock_items.where(stock_location_id: sl1.id).first }
  let(:item2) { variant.stock_items.where(stock_location_id: sl2.id).first }

  before do
    user.stock_locations << sl1
  end

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    # This permission set does not grant `:read` on `StockLocation` at all (see
    # https://github.com/solidusio/solidus/issues/4744): every user already gets
    # `can :read, StockLocation, active: true` from the always-on `:default` role,
    # so a narrower grant here could never actually restrict location visibility —
    # it could only accidentally widen it to inactive locations. Neither of these
    # inactive locations is readable through either permission set.
    it { is_expected.to_not be_able_to(:read, sl1) }
    it { is_expected.to_not be_able_to(:read, sl2) }

    it { is_expected.to be_able_to(:read, item1) }
    it { is_expected.to_not be_able_to(:read, item2) }
  end

  context "when activated, with active locations" do
    let(:sl1) { create :stock_location, active: true }
    let(:sl2) { create :stock_location, active: true }

    before do
      described_class.new(ability).activate!
    end

    # Documents the actual, known limitation reported in #4744: DefaultCustomer
    # grants every user `:read` on any active StockLocation, and `:read` on any
    # StockItem at an active location, regardless of this permission set — so
    # neither is genuinely restrictable to assigned locations once they're
    # active. Only the `:admin` action (not granted by DefaultCustomer) stays
    # scoped to assigned locations.
    it { is_expected.to be_able_to(:read, sl1) }
    it { is_expected.to be_able_to(:read, sl2) }

    it { is_expected.to be_able_to(:read, item1) }
    it { is_expected.to be_able_to(:read, item2) }

    it { is_expected.to be_able_to(:admin, item1) }
    it { is_expected.to_not be_able_to(:admin, item2) }
  end

  context "when not activated" do
    it { is_expected.to_not be_able_to(:read, sl1) }
    it { is_expected.to_not be_able_to(:read, sl2) }

    it { is_expected.to_not be_able_to(:read, item1) }
    it { is_expected.to_not be_able_to(:read, item2) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:display)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:restricted_stock)
    end
  end
end
