# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::UserManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:admin, Solidus.user_class) }
    it { is_expected.to be_able_to(:display, Solidus.user_class) }
    it { is_expected.to be_able_to(:create, Solidus.user_class) }
    it { is_expected.to be_able_to(:update, Solidus.user_class) }
    it { is_expected.to be_able_to(:save_in_address_book, Solidus.user_class) }
    it { is_expected.to be_able_to(:remove_from_address_book, Solidus.user_class) }
    it { is_expected.to be_able_to(:addresses, Solidus.user_class) }
    it { is_expected.to be_able_to(:orders, Solidus.user_class) }
    it { is_expected.to be_able_to(:items, Solidus.user_class) }

    context 'when the user does not have a role' do
      let(:user) { create(:user) }
      it { is_expected.to be_able_to(:update_email, user) }
    end

    context 'when the user has a role' do
      let(:user) { create(:user, spree_roles: [create(:role)]) }
      it { is_expected.not_to be_able_to(:update_email, user) }
    end

    it { is_expected.not_to be_able_to(:delete, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Solidus.user_class) }

    it { is_expected.to be_able_to(:manage, Solidus::StoreCredit) }
    it { is_expected.to be_able_to(:display, Solidus::Role) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:delete, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:update, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:save_in_address_book, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:remove_from_address_book, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:addresses, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:orders, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:items, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:manage, Solidus::StoreCredit) }
    it { is_expected.not_to be_able_to(:display, Solidus::Role) }
  end
end
