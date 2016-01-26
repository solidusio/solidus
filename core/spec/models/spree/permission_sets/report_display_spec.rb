require 'spec_helper'

describe Spree::PermissionSets::ReportDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, :reports) }
    it { is_expected.to be_able_to(:admin, :reports) }
    it { is_expected.to be_able_to(:sales_total, :reports) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, :reports) }
    it { is_expected.not_to be_able_to(:admin, :reports) }
    it { is_expected.not_to be_able_to(:sales_total, :reports) }
  end
end
