# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/dummy_ability'

RSpec.describe Spree::PermissionSets::StockManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Spree::StockItem) }
    it { is_expected.to be_able_to(:show, Spree::StockLocation) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree::StockItem) }
    it { is_expected.not_to be_able_to(:show, Spree::StockLocation) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:management)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:stock)
    end
  end
end
