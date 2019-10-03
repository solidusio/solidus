# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::ConfigurationDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:edit, :general_settings) }
    it { is_expected.to be_able_to(:display, Solidus::TaxCategory) }
    it { is_expected.to be_able_to(:display, Solidus::TaxRate) }
    it { is_expected.to be_able_to(:display, Solidus::Zone) }
    it { is_expected.to be_able_to(:display, Solidus::Country) }
    it { is_expected.to be_able_to(:display, Solidus::State) }
    it { is_expected.to be_able_to(:display, Solidus::PaymentMethod) }
    it { is_expected.to be_able_to(:display, Solidus::Taxonomy) }
    it { is_expected.to be_able_to(:display, Solidus::ShippingMethod) }
    it { is_expected.to be_able_to(:display, Solidus::ShippingCategory) }
    it { is_expected.to be_able_to(:display, Solidus::StockLocation) }
    it { is_expected.to be_able_to(:display, Solidus::StockMovement) }
    it { is_expected.to be_able_to(:display, Solidus::RefundReason) }
    it { is_expected.to be_able_to(:display, Solidus::ReimbursementType) }
    it { is_expected.to be_able_to(:display, Solidus::ReturnReason) }
    it { is_expected.to be_able_to(:admin, :general_settings) }
    it { is_expected.to be_able_to(:admin, Solidus::TaxCategory) }
    it { is_expected.to be_able_to(:admin, Solidus::TaxRate) }
    it { is_expected.to be_able_to(:admin, Solidus::Zone) }
    it { is_expected.to be_able_to(:admin, Solidus::Country) }
    it { is_expected.to be_able_to(:admin, Solidus::State) }
    it { is_expected.to be_able_to(:admin, Solidus::PaymentMethod) }
    it { is_expected.to be_able_to(:admin, Solidus::Taxonomy) }
    it { is_expected.to be_able_to(:admin, Solidus::ShippingMethod) }
    it { is_expected.to be_able_to(:admin, Solidus::ShippingCategory) }
    it { is_expected.to be_able_to(:admin, Solidus::StockLocation) }
    it { is_expected.to be_able_to(:admin, Solidus::StockMovement) }
    it { is_expected.to be_able_to(:admin, Solidus::RefundReason) }
    it { is_expected.to be_able_to(:admin, Solidus::ReimbursementType) }
    it { is_expected.to be_able_to(:admin, Solidus::ReturnReason) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:edit, :general_settings) }
    it { is_expected.not_to be_able_to(:display, Solidus::TaxCategory) }
    it { is_expected.not_to be_able_to(:display, Solidus::TaxRate) }
    it { is_expected.not_to be_able_to(:display, Solidus::Zone) }
    it { is_expected.not_to be_able_to(:display, Solidus::Country) }
    it { is_expected.not_to be_able_to(:display, Solidus::State) }
    it { is_expected.not_to be_able_to(:display, Solidus::PaymentMethod) }
    it { is_expected.not_to be_able_to(:display, Solidus::Taxonomy) }
    it { is_expected.not_to be_able_to(:display, Solidus::ShippingMethod) }
    it { is_expected.not_to be_able_to(:display, Solidus::ShippingCategory) }
    it { is_expected.not_to be_able_to(:display, Solidus::StockLocation) }
    it { is_expected.not_to be_able_to(:display, Solidus::StockMovement) }
    it { is_expected.not_to be_able_to(:display, Solidus::RefundReason) }
    it { is_expected.not_to be_able_to(:display, Solidus::ReimbursementType) }
    it { is_expected.not_to be_able_to(:display, Solidus::ReturnReason) }
    it { is_expected.not_to be_able_to(:admin, :general_settings) }
    it { is_expected.not_to be_able_to(:admin, Solidus::TaxCategory) }
    it { is_expected.not_to be_able_to(:admin, Solidus::TaxRate) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Zone) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Country) }
    it { is_expected.not_to be_able_to(:admin, Solidus::State) }
    it { is_expected.not_to be_able_to(:admin, Solidus::PaymentMethod) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Taxonomy) }
    it { is_expected.not_to be_able_to(:admin, Solidus::ShippingMethod) }
    it { is_expected.not_to be_able_to(:admin, Solidus::ShippingCategory) }
    it { is_expected.not_to be_able_to(:admin, Solidus::StockLocation) }
    it { is_expected.not_to be_able_to(:admin, Solidus::StockMovement) }
    it { is_expected.not_to be_able_to(:admin, Solidus::RefundReason) }
    it { is_expected.not_to be_able_to(:admin, Solidus::ReimbursementType) }
    it { is_expected.not_to be_able_to(:admin, Solidus::ReturnReason) }
  end
end
