# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionAction, type: :model do
  describe "preferences" do
    subject { described_class.new.preferences }

    it { is_expected.to eq({}) }
  end

  describe "#remove_from" do
    class MyPromotionAction < Spree::PromotionAction
      def perform(options = {})
        order = options[:order]
        order.adjustments.create!(amount: 1, order:, source: self, label: "foo")
        true
      end

      def remove_from(_order)
        "Implement your remove logic"
      end
    end

    let(:action) { promotion.actions.first! }
    let!(:promotion) { create(:promotion, promotion_actions: [MyPromotionAction.new]) }
    let(:order) { create(:order) }

    # this adjustment should not get removed
    let!(:other_adjustment) { create(:adjustment, order:, source: nil) }

    it "generates its own partial path" do
      action.perform(order:)
      @action_adjustment = order.adjustments.where(source: action).first!

      expect(action.to_partial_path).to eq "spree/admin/promotions/actions/my_promotion_action"
    end

    it "executes the remove logic" do
      action.perform(order:)
      @action_adjustment = order.adjustments.where(source: action).first!

      expect(action.remove_from(order)).to eq("Implement your remove logic")
    end

    context "when PromotionAction doesn't implement perform method" do
      before { MyPromotionAction.remove_method :perform }

      it "raises RuntimeError" do
        expect { action.perform }.to raise_error(RuntimeError, "perform should be implemented in a sub-class of PromotionAction")
      end
    end

    context "when PromotionAction doesn't implement remove_from method" do
      before { MyPromotionAction.remove_method :remove_from }

      it "raises RuntimeError" do
        expect { action.remove_from(order) }.to raise_error(RuntimeError, "remove_from should be implemented in a sub-class of PromotionAction")
      end
    end
  end
end
