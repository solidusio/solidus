require 'spec_helper'

describe Spree::PermissionSets::ProductManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:manage, Spree::Product) }
    it { should be_able_to(:manage, Spree::Image) }
    it { should be_able_to(:manage, Spree::Variant) }
    it { should be_able_to(:manage, Spree::OptionValue) }
    it { should be_able_to(:manage, Spree::ProductProperty) }
    it { should be_able_to(:manage, Spree::OptionType) }
    it { should be_able_to(:manage, Spree::Property) }
    it { should be_able_to(:manage, Spree::Prototype) }
    it { should be_able_to(:manage, Spree::Taxonomy) }
    it { should be_able_to(:manage, Spree::Taxon) }
    it { should be_able_to(:manage, Spree::Classification) }
  end

  context "when not activated" do
    it { should_not be_able_to(:manage, Spree::Product) }
    it { should_not be_able_to(:manage, Spree::Image) }
    it { should_not be_able_to(:manage, Spree::Variant) }
    it { should_not be_able_to(:manage, Spree::OptionValue) }
    it { should_not be_able_to(:manage, Spree::ProductProperty) }
    it { should_not be_able_to(:manage, Spree::OptionType) }
    it { should_not be_able_to(:manage, Spree::Property) }
    it { should_not be_able_to(:manage, Spree::Prototype) }
    it { should_not be_able_to(:manage, Spree::Taxonomy) }
    it { should_not be_able_to(:manage, Spree::Taxon) }
    it { should_not be_able_to(:manage, Spree::Classification) }
  end
end

