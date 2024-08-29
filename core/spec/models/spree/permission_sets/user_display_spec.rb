# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/dummy_ability"

RSpec.describe Spree::PermissionSets::UserDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:read, Spree.user_class) }
    it { is_expected.to be_able_to(:admin, Spree.user_class) }
    it { is_expected.to be_able_to(:edit, Spree.user_class) }
    it { is_expected.to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.to be_able_to(:orders, Spree.user_class) }
    it { is_expected.to be_able_to(:items, Spree.user_class) }
    it { is_expected.to be_able_to(:read, Spree::StoreCredit) }
    it { is_expected.to be_able_to(:admin, Spree::StoreCredit) }
    it { is_expected.to be_able_to(:read, Spree::Role) }
    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:read, Spree.user_class) }
    it { is_expected.not_to be_able_to(:admin, Spree.user_class) }
    it { is_expected.not_to be_able_to(:edit, Spree.user_class) }
    it { is_expected.not_to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.not_to be_able_to(:orders, Spree.user_class) }
    it { is_expected.not_to be_able_to(:items, Spree.user_class) }
    it { is_expected.not_to be_able_to(:read, Spree::StoreCredit) }
    it { is_expected.not_to be_able_to(:admin, Spree::StoreCredit) }
    it { is_expected.not_to be_able_to(:read, Spree::Role) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:display)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:user)
    end
  end
end
