# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PermissionSets::RestrictedStockManagement do
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

    it { is_expected.to be_able_to(:manage, item1) }
    it { is_expected.to_not be_able_to(:manage, item2) }
  end

  context "when activated, with active locations" do
    let(:sl1) { create :stock_location, active: true }
    let(:sl2) { create :stock_location, active: true }

    before do
      described_class.new(ability).activate!
    end

    # Documents the actual, known limitation reported in #4744: stock location
    # read access is granted to every user via DefaultCustomer regardless of
    # this permission set, including for a location the user isn't assigned to.
    # `:manage` on `StockItem` remains correctly scoped to assigned locations.
    it { is_expected.to be_able_to(:read, sl1) }
    it { is_expected.to be_able_to(:read, sl2) }

    it { is_expected.to be_able_to(:manage, item1) }
    it { is_expected.to_not be_able_to(:manage, item2) }
  end

  context "when not activated" do
    it { is_expected.to_not be_able_to(:read, sl1) }
    it { is_expected.to_not be_able_to(:read, sl2) }

    it { is_expected.to_not be_able_to(:manage, item1) }
    it { is_expected.to_not be_able_to(:manage, item2) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:management)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:restricted_stock)
    end
  end
end
