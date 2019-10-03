# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::ProductManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Solidus::Product) }
    it { is_expected.to be_able_to(:manage, Solidus::Image) }
    it { is_expected.to be_able_to(:manage, Solidus::Variant) }
    it { is_expected.to be_able_to(:manage, Solidus::OptionValue) }
    it { is_expected.to be_able_to(:manage, Solidus::ProductProperty) }
    it { is_expected.to be_able_to(:manage, Solidus::OptionType) }
    it { is_expected.to be_able_to(:manage, Solidus::Property) }
    it { is_expected.to be_able_to(:manage, Solidus::Taxonomy) }
    it { is_expected.to be_able_to(:manage, Solidus::Taxon) }
    it { is_expected.to be_able_to(:manage, Solidus::Classification) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Solidus::Product) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Image) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Variant) }
    it { is_expected.not_to be_able_to(:manage, Solidus::OptionValue) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ProductProperty) }
    it { is_expected.not_to be_able_to(:manage, Solidus::OptionType) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Property) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Taxonomy) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Taxon) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Classification) }
  end
end
