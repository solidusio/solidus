require 'spec_helper'

describe Spree::PermissionSets::ReportDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:display, :reports) }
    it { should be_able_to(:admin, :reports) }
    it { should be_able_to(:sales_total, :reports) }
  end

  context "when not activated" do
    it { should_not be_able_to(:display, :reports) }
    it { should_not be_able_to(:admin, :reports) }
    it { should_not be_able_to(:sales_total, :reports) }
  end
end

