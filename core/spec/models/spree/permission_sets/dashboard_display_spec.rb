require 'spec_helper'

describe Spree::PermissionSets::DashboardDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:admin, :dashboards) }
    it { should be_able_to(:home, :dashboards) }
  end

  context "when not activated" do
    it { should_not be_able_to(:admin, :dashboards) }
    it { should_not be_able_to(:home, :dashboards) }
  end
end

