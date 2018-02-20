# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::ConfigurationDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:edit, :general_settings) }
    it { is_expected.to be_able_to(:display, Spree::TaxCategory) }
    it { is_expected.to be_able_to(:display, Spree::TaxRate) }
    it { is_expected.to be_able_to(:display, Spree::Zone) }
    it { is_expected.to be_able_to(:display, Spree::Country) }
    it { is_expected.to be_able_to(:display, Spree::State) }
    it { is_expected.to be_able_to(:display, Spree::PaymentMethod) }
    it { is_expected.to be_able_to(:display, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:display, Spree::ShippingMethod) }
    it { is_expected.to be_able_to(:display, Spree::ShippingCategory) }
    it { is_expected.to be_able_to(:display, Spree::StockLocation) }
    it { is_expected.to be_able_to(:display, Spree::StockMovement) }
    it { is_expected.to be_able_to(:display, Spree::RefundReason) }
    it { is_expected.to be_able_to(:display, Spree::ReimbursementType) }
    it { is_expected.to be_able_to(:display, Spree::ReturnReason) }
    it { is_expected.to be_able_to(:admin, :general_settings) }
    it { is_expected.to be_able_to(:admin, Spree::TaxCategory) }
    it { is_expected.to be_able_to(:admin, Spree::TaxRate) }
    it { is_expected.to be_able_to(:admin, Spree::Zone) }
    it { is_expected.to be_able_to(:admin, Spree::Country) }
    it { is_expected.to be_able_to(:admin, Spree::State) }
    it { is_expected.to be_able_to(:admin, Spree::PaymentMethod) }
    it { is_expected.to be_able_to(:admin, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:admin, Spree::ShippingMethod) }
    it { is_expected.to be_able_to(:admin, Spree::ShippingCategory) }
    it { is_expected.to be_able_to(:admin, Spree::StockLocation) }
    it { is_expected.to be_able_to(:admin, Spree::StockMovement) }
    it { is_expected.to be_able_to(:admin, Spree::RefundReason) }
    it { is_expected.to be_able_to(:admin, Spree::ReimbursementType) }
    it { is_expected.to be_able_to(:admin, Spree::ReturnReason) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:edit, :general_settings) }
    it { is_expected.not_to be_able_to(:display, Spree::TaxCategory) }
    it { is_expected.not_to be_able_to(:display, Spree::TaxRate) }
    it { is_expected.not_to be_able_to(:display, Spree::Zone) }
    it { is_expected.not_to be_able_to(:display, Spree::Country) }
    it { is_expected.not_to be_able_to(:display, Spree::State) }
    it { is_expected.not_to be_able_to(:display, Spree::PaymentMethod) }
    it { is_expected.not_to be_able_to(:display, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:display, Spree::ShippingMethod) }
    it { is_expected.not_to be_able_to(:display, Spree::ShippingCategory) }
    it { is_expected.not_to be_able_to(:display, Spree::StockLocation) }
    it { is_expected.not_to be_able_to(:display, Spree::StockMovement) }
    it { is_expected.not_to be_able_to(:display, Spree::RefundReason) }
    it { is_expected.not_to be_able_to(:display, Spree::ReimbursementType) }
    it { is_expected.not_to be_able_to(:display, Spree::ReturnReason) }
    it { is_expected.not_to be_able_to(:admin, :general_settings) }
    it { is_expected.not_to be_able_to(:admin, Spree::TaxCategory) }
    it { is_expected.not_to be_able_to(:admin, Spree::TaxRate) }
    it { is_expected.not_to be_able_to(:admin, Spree::Zone) }
    it { is_expected.not_to be_able_to(:admin, Spree::Country) }
    it { is_expected.not_to be_able_to(:admin, Spree::State) }
    it { is_expected.not_to be_able_to(:admin, Spree::PaymentMethod) }
    it { is_expected.not_to be_able_to(:admin, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:admin, Spree::ShippingMethod) }
    it { is_expected.not_to be_able_to(:admin, Spree::ShippingCategory) }
    it { is_expected.not_to be_able_to(:admin, Spree::StockLocation) }
    it { is_expected.not_to be_able_to(:admin, Spree::StockMovement) }
    it { is_expected.not_to be_able_to(:admin, Spree::RefundReason) }
    it { is_expected.not_to be_able_to(:admin, Spree::ReimbursementType) }
    it { is_expected.not_to be_able_to(:admin, Spree::ReturnReason) }
  end
end
