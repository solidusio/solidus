# frozen_string_literal: true

require 'rails_helper'

# Regression test for https://github.com/spree/spree/issues/2179
RSpec.describe Spree::OrderMerger, type: :model do
  let(:variant) { create(:variant) }
  let!(:store) { create(:store, default: true) }
  let(:order_1) { Spree::Order.create }
  let(:order_2) { Spree::Order.create }
  let(:user) { stub_model(Spree::LegacyUser, email: "solidus@example.com") }
  let(:subject) { Spree::OrderMerger.new(order_1) }

  context "merging together two orders with different line items" do
    let(:variant_2) { create(:variant) }

    before do
      order_1.contents.add(variant, 1)
      order_2.contents.add(variant_2, 1)
    end

    context "with line item promotion applied to order 2" do
      let!(:promotion) { create(:promotion, :with_line_item_adjustment, apply_automatically: true) }

      before do
        Spree::PromotionHandler::Cart.new(order_2).activate
        expect(order_2.line_items.flat_map(&:adjustments)).not_to be_empty
      end

      it "does not carry a line item adjustments with the wrong order ID over" do
        subject.merge!(order_2)
        expect(order_1.line_items.flat_map(&:adjustments)).to be_empty
      end
    end
  end
end
