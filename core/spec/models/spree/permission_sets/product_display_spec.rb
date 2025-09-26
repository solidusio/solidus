# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/dummy_ability"

RSpec.describe Spree::PermissionSets::ProductDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:read, Spree::Product) }
    it { is_expected.to be_able_to(:read, Spree::Image) }
    it { is_expected.to be_able_to(:read, Spree::Variant) }
    it { is_expected.to be_able_to(:read, Spree::OptionValue) }
    it { is_expected.to be_able_to(:read, Spree::ProductProperty) }
    it { is_expected.to be_able_to(:read, Spree::OptionType) }
    it { is_expected.to be_able_to(:read, Spree::Property) }
    it { is_expected.to be_able_to(:read, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:read, Spree::Taxon) }
    it { is_expected.to be_able_to(:admin, Spree::Product) }
    it { is_expected.to be_able_to(:admin, Spree::Image) }
    it { is_expected.to be_able_to(:admin, Spree::Variant) }
    it { is_expected.to be_able_to(:admin, Spree::OptionValue) }
    it { is_expected.to be_able_to(:admin, Spree::ProductProperty) }
    it { is_expected.to be_able_to(:admin, Spree::OptionType) }
    it { is_expected.to be_able_to(:admin, Spree::Property) }
    it { is_expected.to be_able_to(:admin, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:admin, Spree::Taxon) }
    it { is_expected.to be_able_to(:edit, Spree::Product) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:read, Spree::Product) }
    it { is_expected.not_to be_able_to(:read, Spree::Image) }
    it { is_expected.not_to be_able_to(:read, Spree::Variant) }
    it { is_expected.not_to be_able_to(:read, Spree::OptionValue) }
    it { is_expected.not_to be_able_to(:read, Spree::ProductProperty) }
    it { is_expected.not_to be_able_to(:read, Spree::OptionType) }
    it { is_expected.not_to be_able_to(:read, Spree::Property) }
    it { is_expected.not_to be_able_to(:read, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:read, Spree::Taxon) }
    it { is_expected.not_to be_able_to(:admin, Spree::Product) }
    it { is_expected.not_to be_able_to(:admin, Spree::Image) }
    it { is_expected.not_to be_able_to(:admin, Spree::Variant) }
    it { is_expected.not_to be_able_to(:admin, Spree::OptionValue) }
    it { is_expected.not_to be_able_to(:admin, Spree::ProductProperty) }
    it { is_expected.not_to be_able_to(:admin, Spree::OptionType) }
    it { is_expected.not_to be_able_to(:admin, Spree::Property) }
    it { is_expected.not_to be_able_to(:admin, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:admin, Spree::Taxon) }
    it { is_expected.not_to be_able_to(:edit, Spree::Product) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:display)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:product)
    end
  end
end
