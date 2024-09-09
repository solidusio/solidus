# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/dummy_ability'

RSpec.describe Spree::PermissionSets::DashboardDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:admin, :dashboards) }
    it { is_expected.to be_able_to(:home, :dashboards) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:admin, :dashboards) }
    it { is_expected.not_to be_able_to(:home, :dashboards) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:other)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:dashboard_display)
    end
  end
end
