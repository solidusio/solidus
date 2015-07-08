require "spec_helper"

describe Spree::Admin::Ability do
  let(:ability) { described_class.new(user) }
  let(:user) { build_stubbed :user }

  describe "#can?" do
    subject { ability }

    before do
      allow(user).to receive(:has_spree_role?).and_return(false)

      allow(user).to receive(:has_spree_role?).
        with(role).
        and_return(has_role)
    end

    context "displaying dashboards" do
      let(:role) { :dashboard_display }

      context "when the user has the dashboard_display role" do
        let(:has_role) { true }

        it { should be_able_to(:admin, :dashboards) }
        it { should be_able_to(:home, :dashboards) }
      end

      context "when the user does not have the dashboard_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:admin, :dashboards) }
        it { should_not be_able_to(:home, :dashboards) }
      end
    end

    context "displaying settings" do
      let(:role) { :configuration_display }

      context "when the user has the configuration_display role" do
        let(:has_role) { true }

        it { should be_able_to(:edit, :general_settings) }
        it { should be_able_to(:display, Spree::TaxCategory) }
        it { should be_able_to(:display, Spree::TaxRate) }
        it { should be_able_to(:display, Spree::Zone) }
        it { should be_able_to(:display, Spree::Country) }
        it { should be_able_to(:display, Spree::State) }
        it { should be_able_to(:display, Spree::PaymentMethod) }
        it { should be_able_to(:display, Spree::Taxonomy) }
        it { should be_able_to(:display, Spree::ShippingMethod) }
        it { should be_able_to(:display, Spree::ShippingCategory) }
        it { should be_able_to(:display, Spree::StockLocation) }
        it { should be_able_to(:display, Spree::StockMovement) }
        it { should be_able_to(:display, Spree::Tracker) }
        it { should be_able_to(:display, Spree::RefundReason) }
        it { should be_able_to(:display, Spree::ReimbursementType) }
        it { should be_able_to(:display, Spree::ReturnReason) }
        it { should be_able_to(:admin, :general_settings) }
        it { should be_able_to(:admin, Spree::TaxCategory) }
        it { should be_able_to(:admin, Spree::TaxRate) }
        it { should be_able_to(:admin, Spree::Zone) }
        it { should be_able_to(:admin, Spree::Country) }
        it { should be_able_to(:admin, Spree::State) }
        it { should be_able_to(:admin, Spree::PaymentMethod) }
        it { should be_able_to(:admin, Spree::Taxonomy) }
        it { should be_able_to(:admin, Spree::ShippingMethod) }
        it { should be_able_to(:admin, Spree::ShippingCategory) }
        it { should be_able_to(:admin, Spree::StockLocation) }
        it { should be_able_to(:admin, Spree::StockMovement) }
        it { should be_able_to(:admin, Spree::Tracker) }
        it { should be_able_to(:admin, Spree::RefundReason) }
        it { should be_able_to(:admin, Spree::ReimbursementType) }
        it { should be_able_to(:admin, Spree::ReturnReason) }
      end

      context "when the user does not have the configuration_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:edit, :general_settings) }
        it { should_not be_able_to(:display, Spree::TaxCategory) }
        it { should_not be_able_to(:display, Spree::TaxRate) }
        it { should_not be_able_to(:display, Spree::Zone) }
        it { should_not be_able_to(:display, Spree::Country) }
        it { should_not be_able_to(:display, Spree::State) }
        it { should_not be_able_to(:display, Spree::PaymentMethod) }
        it { should_not be_able_to(:display, Spree::Taxonomy) }
        it { should_not be_able_to(:display, Spree::ShippingMethod) }
        it { should_not be_able_to(:display, Spree::ShippingCategory) }
        it { should_not be_able_to(:display, Spree::StockLocation) }
        it { should_not be_able_to(:display, Spree::StockMovement) }
        it { should_not be_able_to(:display, Spree::Tracker) }
        it { should_not be_able_to(:display, Spree::RefundReason) }
        it { should_not be_able_to(:display, Spree::ReimbursementType) }
        it { should_not be_able_to(:display, Spree::ReturnReason) }
        it { should_not be_able_to(:admin, :general_settings) }
        it { should_not be_able_to(:admin, Spree::TaxCategory) }
        it { should_not be_able_to(:admin, Spree::TaxRate) }
        it { should_not be_able_to(:admin, Spree::Zone) }
        it { should_not be_able_to(:admin, Spree::Country) }
        it { should_not be_able_to(:admin, Spree::State) }
        it { should_not be_able_to(:admin, Spree::PaymentMethod) }
        it { should_not be_able_to(:admin, Spree::Taxonomy) }
        it { should_not be_able_to(:admin, Spree::ShippingMethod) }
        it { should_not be_able_to(:admin, Spree::ShippingCategory) }
        it { should_not be_able_to(:admin, Spree::StockLocation) }
        it { should_not be_able_to(:admin, Spree::StockMovement) }
        it { should_not be_able_to(:admin, Spree::Tracker) }
        it { should_not be_able_to(:admin, Spree::RefundReason) }
        it { should_not be_able_to(:admin, Spree::ReimbursementType) }
        it { should_not be_able_to(:admin, Spree::ReturnReason) }
      end
    end
  end
end
