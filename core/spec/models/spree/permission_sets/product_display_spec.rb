require 'spec_helper'

describe Spree::PermissionSets::ProductDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:display, Spree::Product) }
    it { should be_able_to(:display, Spree::Image) }
    it { should be_able_to(:display, Spree::Variant) }
    it { should be_able_to(:display, Spree::OptionValue) }
    it { should be_able_to(:display, Spree::ProductProperty) }
    it { should be_able_to(:display, Spree::OptionType) }
    it { should be_able_to(:display, Spree::Property) }
    it { should be_able_to(:display, Spree::Prototype) }
    it { should be_able_to(:display, Spree::Taxonomy) }
    it { should be_able_to(:display, Spree::Taxon) }
    it { should be_able_to(:admin, Spree::Product) }
    it { should be_able_to(:admin, Spree::Image) }
    it { should be_able_to(:admin, Spree::Variant) }
    it { should be_able_to(:admin, Spree::OptionValue) }
    it { should be_able_to(:admin, Spree::ProductProperty) }
    it { should be_able_to(:admin, Spree::OptionType) }
    it { should be_able_to(:admin, Spree::Property) }
    it { should be_able_to(:admin, Spree::Prototype) }
    it { should be_able_to(:admin, Spree::Taxonomy) }
    it { should be_able_to(:admin, Spree::Taxon) }
    it { should be_able_to(:edit, Spree::Product) }
  end

  context "when not activated" do
    it { should_not be_able_to(:display, Spree::Product) }
    it { should_not be_able_to(:display, Spree::Image) }
    it { should_not be_able_to(:display, Spree::Variant) }
    it { should_not be_able_to(:display, Spree::OptionValue) }
    it { should_not be_able_to(:display, Spree::ProductProperty) }
    it { should_not be_able_to(:display, Spree::OptionType) }
    it { should_not be_able_to(:display, Spree::Property) }
    it { should_not be_able_to(:display, Spree::Prototype) }
    it { should_not be_able_to(:display, Spree::Taxonomy) }
    it { should_not be_able_to(:display, Spree::Taxon) }
    it { should_not be_able_to(:admin, Spree::Product) }
    it { should_not be_able_to(:admin, Spree::Image) }
    it { should_not be_able_to(:admin, Spree::Variant) }
    it { should_not be_able_to(:admin, Spree::OptionValue) }
    it { should_not be_able_to(:admin, Spree::ProductProperty) }
    it { should_not be_able_to(:admin, Spree::OptionType) }
    it { should_not be_able_to(:admin, Spree::Property) }
    it { should_not be_able_to(:admin, Spree::Prototype) }
    it { should_not be_able_to(:admin, Spree::Taxonomy) }
    it { should_not be_able_to(:admin, Spree::Taxon) }
    it { should_not be_able_to(:edit, Spree::Product) }
  end
end

