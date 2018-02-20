# frozen_string_literal: true

require 'rails_helper'

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

    it { is_expected.to be_able_to(:display, sl1) }
    it { is_expected.to_not be_able_to(:display, sl2) }

    it { is_expected.to be_able_to(:manage, item1) }
    it { is_expected.to_not be_able_to(:manage, item2) }
  end

  context "when not activated" do
    it { is_expected.to_not be_able_to(:display, sl1) }
    it { is_expected.to_not be_able_to(:display, sl2) }

    it { is_expected.to_not be_able_to(:manage, item1) }
    it { is_expected.to_not be_able_to(:manage, item2) }
  end
end
