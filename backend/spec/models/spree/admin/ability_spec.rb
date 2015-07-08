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

    context "displaying reports" do
      let(:role) { :report_display }

      context "when the user has the report_display role" do
        let(:has_role) { true }

        it { should be_able_to(:display, :reports) }
        it { should be_able_to(:admin, :reports) }
        it { should be_able_to(:sales_total, :reports) }
      end

      context "when the user does not have the report_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:display, :reports) }
        it { should_not be_able_to(:admin, :reports) }
        it { should_not be_able_to(:sales_total, :reports) }
      end
    end

    context "managing stock" do
      let(:role) { :stock_management }

      context "when the user has the stock_management role" do
        let(:has_role) { true }

        it { should be_able_to(:manage, Spree::StockItem) }
        it { should be_able_to(:manage, Spree::StockTransfer) }
        it { should be_able_to(:manage, Spree::TransferItem) }
      end

      context "when the user does not have the stock_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:manage, Spree::StockItem) }
        it { should_not be_able_to(:manage, Spree::StockTransfer) }
        it { should_not be_able_to(:manage, Spree::TransferItem) }
      end
    end

    context "displaying stock" do
      let(:role) { :stock_display }

      context "when the user has the stock_display role" do
        let(:has_role) { true }

        it { should be_able_to(:display, Spree::StockItem) }
        it { should be_able_to(:display, Spree::StockTransfer) }
        it { should be_able_to(:admin, Spree::StockItem) }
        it { should be_able_to(:admin, Spree::StockTransfer) }
      end

      context "when the user does not have the stock_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:display, Spree::StockItem) }
        it { should_not be_able_to(:display, Spree::StockTransfer) }
        it { should_not be_able_to(:admin, Spree::StockItem) }
        it { should_not be_able_to(:admin, Spree::StockTransfer) }
      end
    end

    context "managing products" do
      let(:role) { :product_management }

      context "when the user has the product_management role" do
        let(:has_role) { true }

        it { should be_able_to(:manage, Spree::Product) }
        it { should be_able_to(:manage, Spree::Image) }
        it { should be_able_to(:manage, Spree::Variant) }
        it { should be_able_to(:manage, Spree::OptionValue) }
        it { should be_able_to(:manage, Spree::ProductProperty) }
        it { should be_able_to(:manage, Spree::OptionType) }
        it { should be_able_to(:manage, Spree::Property) }
        it { should be_able_to(:manage, Spree::Prototype) }
        it { should be_able_to(:manage, Spree::Taxonomy) }
        it { should be_able_to(:manage, Spree::Taxon) }
        it { should be_able_to(:manage, Spree::Classification) }
      end

      context "when the user does not have the product_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:manage, Spree::Product) }
        it { should_not be_able_to(:manage, Spree::Image) }
        it { should_not be_able_to(:manage, Spree::Variant) }
        it { should_not be_able_to(:manage, Spree::OptionValue) }
        it { should_not be_able_to(:manage, Spree::ProductProperty) }
        it { should_not be_able_to(:manage, Spree::OptionType) }
        it { should_not be_able_to(:manage, Spree::Property) }
        it { should_not be_able_to(:manage, Spree::Prototype) }
        it { should_not be_able_to(:manage, Spree::Taxonomy) }
        it { should_not be_able_to(:manage, Spree::Taxon) }
        it { should_not be_able_to(:manage, Spree::Classification) }
      end
    end

    context "displaying products" do
      let(:role) { :product_display }

      context "when the user has the product_displayj role" do
        let(:has_role) { true }

        it { should be_able_to(:display, Spree::Product) }
        it { should be_able_to(:display, Spree::Image) }
        it { should be_able_to(:display, Spree::Variant) }
        it { should be_able_to(:display, Spree::OptionValue) }
        it { should be_able_to(:display, Spree::ProductProperty) }
        it { should be_able_to(:display, Spree::OptionType) }
        it { should be_able_to(:display, Spree::Property) }
        it { should be_able_to(:display, Spree::Prototype) }
        it { should be_able_to(:display, Spree::Taxonomy) }
        it { should be_able_to(:display, Spree::Taxon) }
        it { should be_able_to(:admin, Spree::Product) }
        it { should be_able_to(:admin, Spree::Image) }
        it { should be_able_to(:admin, Spree::Variant) }
        it { should be_able_to(:admin, Spree::OptionValue) }
        it { should be_able_to(:admin, Spree::ProductProperty) }
        it { should be_able_to(:admin, Spree::OptionType) }
        it { should be_able_to(:admin, Spree::Property) }
        it { should be_able_to(:admin, Spree::Prototype) }
        it { should be_able_to(:admin, Spree::Taxonomy) }
        it { should be_able_to(:admin, Spree::Taxon) }
        it { should be_able_to(:edit, Spree::Product) }
      end

      context "when the user does not have the product_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:display, Spree::Product) }
        it { should_not be_able_to(:display, Spree::Image) }
        it { should_not be_able_to(:display, Spree::Variant) }
        it { should_not be_able_to(:display, Spree::OptionValue) }
        it { should_not be_able_to(:display, Spree::ProductProperty) }
        it { should_not be_able_to(:display, Spree::OptionType) }
        it { should_not be_able_to(:display, Spree::Property) }
        it { should_not be_able_to(:display, Spree::Prototype) }
        it { should_not be_able_to(:display, Spree::Taxonomy) }
        it { should_not be_able_to(:display, Spree::Taxon) }
        it { should_not be_able_to(:admin, Spree::Product) }
        it { should_not be_able_to(:admin, Spree::Image) }
        it { should_not be_able_to(:admin, Spree::Variant) }
        it { should_not be_able_to(:admin, Spree::OptionValue) }
        it { should_not be_able_to(:admin, Spree::ProductProperty) }
        it { should_not be_able_to(:admin, Spree::OptionType) }
        it { should_not be_able_to(:admin, Spree::Property) }
        it { should_not be_able_to(:admin, Spree::Prototype) }
        it { should_not be_able_to(:admin, Spree::Taxonomy) }
        it { should_not be_able_to(:admin, Spree::Taxon) }
        it { should_not be_able_to(:edit, Spree::Product) }
      end
    end

    context "managing users" do
      let(:role) { :user_management }

      context "when the user has the user_management role" do
        let(:has_role) { true }

        it { should be_able_to(:manage, Spree.user_class) }
        it { should be_able_to(:manage, Spree::StoreCredit) }
        it { should be_able_to(:display, Spree::Role) }
      end

      context "when the user does not have the user_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:manage, Spree.user_class) }
        it { should_not be_able_to(:manage, Spree::StoreCredit) }
        it { should_not be_able_to(:display, Spree::Role) }
      end
    end

    context "displaying users" do
      let(:role) { :user_display }

      context "when the user has the user_display role" do
        let(:has_role) { true }

        it { should be_able_to(:display, Spree.user_class) }
        it { should be_able_to(:admin, Spree.user_class) }
        it { should be_able_to(:edit, Spree.user_class) }
        it { should be_able_to(:addresses, Spree.user_class) }
        it { should be_able_to(:orders, Spree.user_class) }
        it { should be_able_to(:items, Spree.user_class) }
        it { should be_able_to(:display, Spree::StoreCredit) }
        it { should be_able_to(:admin, Spree::StoreCredit) }
        it { should be_able_to(:display, Spree::Role) }
      end

      context "when the user does not have the user_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:display, Spree.user_class) }
        it { should_not be_able_to(:admin, Spree.user_class) }
        it { should_not be_able_to(:edit, Spree.user_class) }
        it { should_not be_able_to(:addresses, Spree.user_class) }
        it { should_not be_able_to(:orders, Spree.user_class) }
        it { should_not be_able_to(:items, Spree.user_class) }
        it { should_not be_able_to(:display, Spree::StoreCredit) }
        it { should_not be_able_to(:admin, Spree::StoreCredit) }
        it { should_not be_able_to(:display, Spree::Role) }
      end
    end

    context "managing settings" do
      let(:role) { :configuration_management }

      context "when the user has the configuration_management role" do
        let(:has_role) { true }

        it { should be_able_to(:manage, :general_settings) }
        it { should be_able_to(:manage, Spree::TaxCategory) }
        it { should be_able_to(:manage, Spree::TaxRate) }
        it { should be_able_to(:manage, Spree::Zone) }
        it { should be_able_to(:manage, Spree::Country) }
        it { should be_able_to(:manage, Spree::State) }
        it { should be_able_to(:manage, Spree::PaymentMethod) }
        it { should be_able_to(:manage, Spree::Taxonomy) }
        it { should be_able_to(:manage, Spree::ShippingMethod) }
        it { should be_able_to(:manage, Spree::ShippingCategory) }
        it { should be_able_to(:manage, Spree::StockLocation) }
        it { should be_able_to(:manage, Spree::StockMovement) }
        it { should be_able_to(:manage, Spree::Tracker) }
        it { should be_able_to(:manage, Spree::RefundReason) }
        it { should be_able_to(:manage, Spree::ReimbursementType) }
        it { should be_able_to(:manage, Spree::ReturnReason) }
      end

      context "when the user does not have the configuration_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:manage, :general_settings) }
        it { should_not be_able_to(:manage, Spree::TaxCategory) }
        it { should_not be_able_to(:manage, Spree::TaxRate) }
        it { should_not be_able_to(:manage, Spree::Zone) }
        it { should_not be_able_to(:manage, Spree::Country) }
        it { should_not be_able_to(:manage, Spree::State) }
        it { should_not be_able_to(:manage, Spree::PaymentMethod) }
        it { should_not be_able_to(:manage, Spree::Taxonomy) }
        it { should_not be_able_to(:manage, Spree::ShippingMethod) }
        it { should_not be_able_to(:manage, Spree::ShippingCategory) }
        it { should_not be_able_to(:manage, Spree::StockLocation) }
        it { should_not be_able_to(:manage, Spree::StockMovement) }
        it { should_not be_able_to(:manage, Spree::Tracker) }
        it { should_not be_able_to(:manage, Spree::RefundReason) }
        it { should_not be_able_to(:manage, Spree::ReimbursementType) }
        it { should_not be_able_to(:manage, Spree::ReturnReason) }
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
