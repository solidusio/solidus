# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::UserDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Solidus.user_class) }
    it { is_expected.to be_able_to(:admin, Solidus.user_class) }
    it { is_expected.to be_able_to(:edit, Solidus.user_class) }
    it { is_expected.to be_able_to(:addresses, Solidus.user_class) }
    it { is_expected.to be_able_to(:orders, Solidus.user_class) }
    it { is_expected.to be_able_to(:items, Solidus.user_class) }
    it { is_expected.to be_able_to(:display, Solidus::StoreCredit) }
    it { is_expected.to be_able_to(:admin, Solidus::StoreCredit) }
    it { is_expected.to be_able_to(:display, Solidus::Role) }
    it { is_expected.not_to be_able_to(:delete, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Solidus.user_class) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:admin, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:edit, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:addresses, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:orders, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:items, Solidus.user_class) }
    it { is_expected.not_to be_able_to(:display, Solidus::StoreCredit) }
    it { is_expected.not_to be_able_to(:admin, Solidus::StoreCredit) }
    it { is_expected.not_to be_able_to(:display, Solidus::Role) }
  end
end
