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

    context "managing promotions" do
      let(:role) { :promotion_management}

      context "when the user has the promotion_management role" do
        let(:has_role) { true }

        it { should be_able_to(:manage, Spree::Promotion) }
        it { should be_able_to(:manage, Spree::PromotionRule) }
        it { should be_able_to(:manage, Spree::PromotionAction) }
        it { should be_able_to(:manage, Spree::PromotionCategory) }
      end

      context "when the user does not have the promotion_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:manage, Spree::Promotion) }
        it { should_not be_able_to(:manage, Spree::PromotionRule) }
        it { should_not be_able_to(:manage, Spree::PromotionAction) }
        it { should_not be_able_to(:manage, Spree::PromotionCategory) }
      end
    end

    context "displaying promotions" do
      let(:role) { :promotion_display }

      context "when the user has the promotion_display role" do
        let(:has_role) { true }

        it { should be_able_to(:display, Spree::Promotion) }
        it { should be_able_to(:display, Spree::PromotionRule) }
        it { should be_able_to(:display, Spree::PromotionAction) }
        it { should be_able_to(:display, Spree::PromotionCategory) }
        it { should be_able_to(:admin, Spree::Promotion) }
        it { should be_able_to(:admin, Spree::PromotionRule) }
        it { should be_able_to(:admin, Spree::PromotionAction) }
        it { should be_able_to(:admin, Spree::PromotionCategory) }
      end

      context "when the user does not have the promotion_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:display, Spree::Promotion) }
        it { should_not be_able_to(:display, Spree::PromotionRule) }
        it { should_not be_able_to(:display, Spree::PromotionAction) }
        it { should_not be_able_to(:display, Spree::PromotionCategory) }
        it { should_not be_able_to(:admin, Spree::Promotion) }
        it { should_not be_able_to(:admin, Spree::PromotionRule) }
        it { should_not be_able_to(:admin, Spree::PromotionAction) }
        it { should_not be_able_to(:admin, Spree::PromotionCategory) }
      end
    end

    context "managing orders" do
      let(:role) { :order_management }

      context "when the user has the order_management role" do
        let(:has_role) { true }

        it { should be_able_to(:manage, Spree::Order) }
        it { should be_able_to(:manage, Spree::Payment) }
        it { should be_able_to(:manage, Spree::Shipment) }
        it { should be_able_to(:manage, Spree::Adjustment) }
        it { should be_able_to(:manage, Spree::LineItem) }
        it { should be_able_to(:manage, Spree::ReturnAuthorization) }
        it { should be_able_to(:manage, Spree::CustomerReturn) }
      end

      context "when the user does not have the order_management role" do
        let(:has_role) { false }

        it { should_not be_able_to(:manage, Spree::Order) }
        it { should_not be_able_to(:manage, Spree::Payment) }
        it { should_not be_able_to(:manage, Spree::Shipment) }
        it { should_not be_able_to(:manage, Spree::Adjustment) }
        it { should_not be_able_to(:manage, Spree::LineItem) }
        it { should_not be_able_to(:manage, Spree::ReturnAuthorization) }
        it { should_not be_able_to(:manage, Spree::CustomerReturn) }
      end
    end

    context "displaying orders" do
      let(:role) { :order_display }

      context "when the user has the order_display role" do
        let(:has_role) { true }

        it { should be_able_to(:display, Spree::Order) }
        it { should be_able_to(:display, Spree::Payment) }
        it { should be_able_to(:display, Spree::Shipment) }
        it { should be_able_to(:display, Spree::Adjustment) }
        it { should be_able_to(:display, Spree::LineItem) }
        it { should be_able_to(:display, Spree::ReturnAuthorization) }
        it { should be_able_to(:display, Spree::CustomerReturn) }
        it { should be_able_to(:admin, Spree::Order) }
        it { should be_able_to(:admin, Spree::Payment) }
        it { should be_able_to(:admin, Spree::Shipment) }
        it { should be_able_to(:admin, Spree::Adjustment) }
        it { should be_able_to(:admin, Spree::LineItem) }
        it { should be_able_to(:admin, Spree::ReturnAuthorization) }
        it { should be_able_to(:admin, Spree::CustomerReturn) }
        it { should be_able_to(:edit, Spree::Order) }
        it { should be_able_to(:cart, Spree::Order) }
      end

      context "when the user does not have the order_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:display, Spree::Order) }
        it { should_not be_able_to(:display, Spree::Payment) }
        it { should_not be_able_to(:display, Spree::Shipment) }
        it { should_not be_able_to(:display, Spree::Adjustment) }
        it { should_not be_able_to(:display, Spree::LineItem) }
        it { should_not be_able_to(:display, Spree::ReturnAuthorization) }
        it { should_not be_able_to(:display, Spree::CustomerReturn) }
        it { should_not be_able_to(:admin, Spree::Order) }
        it { should_not be_able_to(:admin, Spree::Payment) }
        it { should_not be_able_to(:admin, Spree::Shipment) }
        it { should_not be_able_to(:admin, Spree::Adjustment) }
        it { should_not be_able_to(:admin, Spree::LineItem) }
        it { should_not be_able_to(:admin, Spree::ReturnAuthorization) }
        it { should_not be_able_to(:admin, Spree::CustomerReturn) }
        it { should_not be_able_to(:edit, Spree::Order) }
        it { should_not be_able_to(:cart, Spree::Order) }
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
  end
end
