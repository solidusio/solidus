# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/dummy_ability"

RSpec.describe Spree::PermissionSets::ProductManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Spree::Product) }
    it { is_expected.to be_able_to(:manage, Spree::Image) }
    it { is_expected.to be_able_to(:manage, Spree::Variant) }
    it { is_expected.to be_able_to(:manage, Spree::OptionValue) }
    it { is_expected.to be_able_to(:manage, Spree::ProductProperty) }
    it { is_expected.to be_able_to(:manage, Spree::OptionType) }
    it { is_expected.to be_able_to(:manage, Spree::Property) }
    it { is_expected.to be_able_to(:manage, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:manage, Spree::Taxon) }
    it { is_expected.to be_able_to(:manage, Spree::Classification) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree::Product) }
    it { is_expected.not_to be_able_to(:manage, Spree::Image) }
    it { is_expected.not_to be_able_to(:manage, Spree::Variant) }
    it { is_expected.not_to be_able_to(:manage, Spree::OptionValue) }
    it { is_expected.not_to be_able_to(:manage, Spree::ProductProperty) }
    it { is_expected.not_to be_able_to(:manage, Spree::OptionType) }
    it { is_expected.not_to be_able_to(:manage, Spree::Property) }
    it { is_expected.not_to be_able_to(:manage, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:manage, Spree::Taxon) }
    it { is_expected.not_to be_able_to(:manage, Spree::Classification) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:management)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:product)
    end
  end
end
