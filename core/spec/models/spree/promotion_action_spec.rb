require 'spec_helper'

describe Spree::PromotionAction, type: :model do
  describe '#remove_from' do
    class MyPromotionAction < Spree::PromotionAction
      def perform(options = {})
        order = options[:order]
        order.adjustments.create!(amount: 1, order: order, source: self, label: 'foo')
        true
      end
    end

    let(:action) { promotion.actions.first! }
    let!(:promotion) { create(:promotion, promotion_actions: [MyPromotionAction.new]) }
    let(:order) { create(:order) }

    # this adjustment should not get removed
    let!(:other_adjustment) { create(:adjustment, order: order, source: nil) }

    before do
      action.perform(order: order)
      @action_adjustment = order.adjustments.where(source: action).first!
    end

    it 'removes the action adjustment' do
      expect(order.adjustments).to match_array([other_adjustment, @action_adjustment])

      expect(Spree::Deprecation).to(
        receive(:warn).
        with(/"MyPromotionAction" does not define #remove_from/, anything)
      )

      action.remove_from(order)

      expect(order.adjustments).to eq([other_adjustment])
    end
  end
end
