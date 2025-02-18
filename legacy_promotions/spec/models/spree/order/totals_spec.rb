# frozen_string_literal: true

require "rails_helper"

module Spree
  RSpec.describe Order, type: :model do
    let(:order) { create(:order) }
    let(:shirt) { create(:variant) }

    context "adds item to cart and activates promo" do
      let(:promotion) { Promotion.create name: "Huhu", apply_automatically: true }
      let(:calculator) { Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 10) }
      let!(:action) { Promotion::Actions::CreateAdjustment.create(promotion:, calculator:) }

      before { order.contents.add(shirt, 1) }

      context "item quantity changes" do
        it "recalculates order adjustments" do
          expect {
            order.contents.add(shirt, 3)
          }.to change { order.adjustments.eligible.pluck(:amount) }
        end
      end
    end
  end
end
