# frozen_string_literal: true

require 'rails_helper'
require "spree/testing_support/shared_examples/order_factory"
require 'spree/testing_support/shared_examples/working_factory'

RSpec.describe 'order factory' do
  let(:factory_class) { Spree::Order }

  describe 'completed order with promotion' do
    let(:factory) { :completed_order_with_promotion }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'
    it_behaves_like 'supplied completed_at is respected'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to be_complete

        expect(order.order_promotions.count).to eq(1)
        order_promotion = order.order_promotions[0]
        expect(order_promotion.promotion_code.promotion).to eq order_promotion.promotion
      end
    end

    context 'with a promotion with an action' do
      let(:promotion) { create(:promotion, :with_line_item_adjustment) }
      it "has the expected attributes" do
        order = create(factory, promotion:)
        aggregate_failures do
          expect(order).to be_completed
          expect(order).to be_complete

          expect(order.line_items[0].adjustments.count).to eq 1
          adjustment = order.line_items[0].adjustments[0]
          expect(adjustment).to have_attributes(
            amount: -10,
            eligible: true,
            order_id: order.id
          )
        end
      end
    end
  end
end
