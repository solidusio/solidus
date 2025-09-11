# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/dummy_ability"

RSpec.describe Spree::PermissionSets::UserManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:admin, Spree.user_class) }
    it { is_expected.to be_able_to(:read, Spree.user_class) }
    it { is_expected.to be_able_to(:create, Spree.user_class) }
    it { is_expected.to be_able_to(:update, Spree.user_class) }
    it { is_expected.to be_able_to(:save_in_address_book, Spree.user_class) }
    it { is_expected.to be_able_to(:remove_from_address_book, Spree.user_class) }
    it { is_expected.to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.to be_able_to(:orders, Spree.user_class) }
    it { is_expected.to be_able_to(:items, Spree.user_class) }

    context "when the user does not have a role" do
      let(:user) { create(:user) }
      it { is_expected.to be_able_to(:update_email, user) }
      it { is_expected.to be_able_to(:update_password, user) }
    end

    context "when the user has a role" do
      let(:user) { create(:user, spree_roles: [create(:role)]) }
      it { is_expected.not_to be_able_to(:update_email, user) }
      it { is_expected.not_to be_able_to(:update_password, user) }
    end

    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }

    it { is_expected.to be_able_to(:manage, Spree::StoreCredit) }
    it { is_expected.to be_able_to(:read, Spree::Role) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree.user_class) }
    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
    it { is_expected.not_to be_able_to(:update, Spree.user_class) }
    it { is_expected.not_to be_able_to(:save_in_address_book, Spree.user_class) }
    it { is_expected.not_to be_able_to(:remove_from_address_book, Spree.user_class) }
    it { is_expected.not_to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.not_to be_able_to(:orders, Spree.user_class) }
    it { is_expected.not_to be_able_to(:items, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
    it { is_expected.not_to be_able_to(:manage, Spree::StoreCredit) }
    it { is_expected.not_to be_able_to(:read, Spree::Role) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:management)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:user)
    end
  end
end
