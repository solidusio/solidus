# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::ProductDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Solidus::Product) }
    it { is_expected.to be_able_to(:display, Solidus::Image) }
    it { is_expected.to be_able_to(:display, Solidus::Variant) }
    it { is_expected.to be_able_to(:display, Solidus::OptionValue) }
    it { is_expected.to be_able_to(:display, Solidus::ProductProperty) }
    it { is_expected.to be_able_to(:display, Solidus::OptionType) }
    it { is_expected.to be_able_to(:display, Solidus::Property) }
    it { is_expected.to be_able_to(:display, Solidus::Taxonomy) }
    it { is_expected.to be_able_to(:display, Solidus::Taxon) }
    it { is_expected.to be_able_to(:admin, Solidus::Product) }
    it { is_expected.to be_able_to(:admin, Solidus::Image) }
    it { is_expected.to be_able_to(:admin, Solidus::Variant) }
    it { is_expected.to be_able_to(:admin, Solidus::OptionValue) }
    it { is_expected.to be_able_to(:admin, Solidus::ProductProperty) }
    it { is_expected.to be_able_to(:admin, Solidus::OptionType) }
    it { is_expected.to be_able_to(:admin, Solidus::Property) }
    it { is_expected.to be_able_to(:admin, Solidus::Taxonomy) }
    it { is_expected.to be_able_to(:admin, Solidus::Taxon) }
    it { is_expected.to be_able_to(:edit, Solidus::Product) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Solidus::Product) }
    it { is_expected.not_to be_able_to(:display, Solidus::Image) }
    it { is_expected.not_to be_able_to(:display, Solidus::Variant) }
    it { is_expected.not_to be_able_to(:display, Solidus::OptionValue) }
    it { is_expected.not_to be_able_to(:display, Solidus::ProductProperty) }
    it { is_expected.not_to be_able_to(:display, Solidus::OptionType) }
    it { is_expected.not_to be_able_to(:display, Solidus::Property) }
    it { is_expected.not_to be_able_to(:display, Solidus::Taxonomy) }
    it { is_expected.not_to be_able_to(:display, Solidus::Taxon) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Product) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Image) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Variant) }
    it { is_expected.not_to be_able_to(:admin, Solidus::OptionValue) }
    it { is_expected.not_to be_able_to(:admin, Solidus::ProductProperty) }
    it { is_expected.not_to be_able_to(:admin, Solidus::OptionType) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Property) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Taxonomy) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Taxon) }
    it { is_expected.not_to be_able_to(:edit, Solidus::Product) }
  end
end
