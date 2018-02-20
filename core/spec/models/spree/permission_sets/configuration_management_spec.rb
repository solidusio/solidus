# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::ConfigurationManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, :general_settings) }
    it { is_expected.to be_able_to(:manage, Spree::TaxCategory) }
    it { is_expected.to be_able_to(:manage, Spree::TaxRate) }
    it { is_expected.to be_able_to(:manage, Spree::Zone) }
    it { is_expected.to be_able_to(:manage, Spree::Country) }
    it { is_expected.to be_able_to(:manage, Spree::State) }
    it { is_expected.to be_able_to(:manage, Spree::PaymentMethod) }
    it { is_expected.to be_able_to(:manage, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:manage, Spree::ShippingMethod) }
    it { is_expected.to be_able_to(:manage, Spree::ShippingCategory) }
    it { is_expected.to be_able_to(:manage, Spree::StockLocation) }
    it { is_expected.to be_able_to(:manage, Spree::StockMovement) }
    it { is_expected.to be_able_to(:manage, Spree::RefundReason) }
    it { is_expected.to be_able_to(:manage, Spree::ReimbursementType) }
    it { is_expected.to be_able_to(:manage, Spree::ReturnReason) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, :general_settings) }
    it { is_expected.not_to be_able_to(:manage, Spree::TaxCategory) }
    it { is_expected.not_to be_able_to(:manage, Spree::TaxRate) }
    it { is_expected.not_to be_able_to(:manage, Spree::Zone) }
    it { is_expected.not_to be_able_to(:manage, Spree::Country) }
    it { is_expected.not_to be_able_to(:manage, Spree::State) }
    it { is_expected.not_to be_able_to(:manage, Spree::PaymentMethod) }
    it { is_expected.not_to be_able_to(:manage, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:manage, Spree::ShippingMethod) }
    it { is_expected.not_to be_able_to(:manage, Spree::ShippingCategory) }
    it { is_expected.not_to be_able_to(:manage, Spree::StockLocation) }
    it { is_expected.not_to be_able_to(:manage, Spree::StockMovement) }
    it { is_expected.not_to be_able_to(:manage, Spree::RefundReason) }
    it { is_expected.not_to be_able_to(:manage, Spree::ReimbursementType) }
    it { is_expected.not_to be_able_to(:manage, Spree::ReturnReason) }
  end
end
