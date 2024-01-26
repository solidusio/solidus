# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::LineItem, type: :model do
  describe "#total_before_tax" do
    let(:line_item) { create(:line_item, price: 10, quantity: 2) }

    let!(:admin_adjustment) { create(:adjustment, adjustable: line_item, order: line_item.order, amount: -1, source: nil) }
    let!(:promo_adjustment) { create(:adjustment, adjustable: line_item, order: line_item.order, amount: -2, source: promo_action) }
    let!(:ineligible_promo_adjustment) { create(:adjustment, eligible: false, adjustable: line_item, order: line_item.order, amount: -4, source: promo_action) }
    let(:promo_action) { promo.actions[0] }
    let(:promo) { create(:promotion, :with_line_item_adjustment) }

    it "returns the amount minus any adjustments" do
      expect(line_item.total_before_tax).to eq(20 - 1 - 2)
    end
  end
end
