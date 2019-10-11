# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::ConfigurationManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, :general_settings) }
    it { is_expected.to be_able_to(:manage, Solidus::TaxCategory) }
    it { is_expected.to be_able_to(:manage, Solidus::TaxRate) }
    it { is_expected.to be_able_to(:manage, Solidus::Zone) }
    it { is_expected.to be_able_to(:manage, Solidus::Country) }
    it { is_expected.to be_able_to(:manage, Solidus::State) }
    it { is_expected.to be_able_to(:manage, Solidus::PaymentMethod) }
    it { is_expected.to be_able_to(:manage, Solidus::Taxonomy) }
    it { is_expected.to be_able_to(:manage, Solidus::ShippingMethod) }
    it { is_expected.to be_able_to(:manage, Solidus::ShippingCategory) }
    it { is_expected.to be_able_to(:manage, Solidus::StockLocation) }
    it { is_expected.to be_able_to(:manage, Solidus::StockMovement) }
    it { is_expected.to be_able_to(:manage, Solidus::RefundReason) }
    it { is_expected.to be_able_to(:manage, Solidus::ReimbursementType) }
    it { is_expected.to be_able_to(:manage, Solidus::ReturnReason) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, :general_settings) }
    it { is_expected.not_to be_able_to(:manage, Solidus::TaxCategory) }
    it { is_expected.not_to be_able_to(:manage, Solidus::TaxRate) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Zone) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Country) }
    it { is_expected.not_to be_able_to(:manage, Solidus::State) }
    it { is_expected.not_to be_able_to(:manage, Solidus::PaymentMethod) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Taxonomy) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ShippingMethod) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ShippingCategory) }
    it { is_expected.not_to be_able_to(:manage, Solidus::StockLocation) }
    it { is_expected.not_to be_able_to(:manage, Solidus::StockMovement) }
    it { is_expected.not_to be_able_to(:manage, Solidus::RefundReason) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ReimbursementType) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ReturnReason) }
  end
end
