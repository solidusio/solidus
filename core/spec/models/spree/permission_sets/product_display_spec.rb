# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::ProductDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Spree::Product) }
    it { is_expected.to be_able_to(:display, Spree::Image) }
    it { is_expected.to be_able_to(:display, Spree::Variant) }
    it { is_expected.to be_able_to(:display, Spree::OptionValue) }
    it { is_expected.to be_able_to(:display, Spree::ProductProperty) }
    it { is_expected.to be_able_to(:display, Spree::OptionType) }
    it { is_expected.to be_able_to(:display, Spree::Property) }
    it { is_expected.to be_able_to(:display, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:display, Spree::Taxon) }
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
    it { is_expected.not_to be_able_to(:display, Spree::Product) }
    it { is_expected.not_to be_able_to(:display, Spree::Image) }
    it { is_expected.not_to be_able_to(:display, Spree::Variant) }
    it { is_expected.not_to be_able_to(:display, Spree::OptionValue) }
    it { is_expected.not_to be_able_to(:display, Spree::ProductProperty) }
    it { is_expected.not_to be_able_to(:display, Spree::OptionType) }
    it { is_expected.not_to be_able_to(:display, Spree::Property) }
    it { is_expected.not_to be_able_to(:display, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:display, Spree::Taxon) }
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
end
