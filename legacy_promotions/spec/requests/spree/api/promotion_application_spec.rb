# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Promotion application", type: :request do
  before do
    stub_authentication!
  end

  context "with an available promotion" do
    let!(:order) { create(:order_with_line_items, line_items_count: 1) }
    let!(:promotion) do
      promotion = create(:promotion, name: "10% off", code: "10off")
      calculator = Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: "10")
      action = Spree::Promotion::Actions::CreateItemAdjustments.create(calculator:)
      promotion.actions << action
      promotion
    end

    it "can apply a coupon code to the order" do
      expect(order.total).to eq(110.00)
      post spree.api_order_coupon_codes_path(order), params: {coupon_code: "10off", order_token: order.guest_token}
      expect(response.status).to eq(200)
      expect(order.reload.total).to eq(109.00)
      expect(json_response["success"]).to eq("The coupon code was successfully applied to your order.")
      expect(json_response["error"]).to be_blank
      expect(json_response["successful"]).to be true
      expect(json_response["status_code"]).to eq("coupon_code_applied")
    end

    context "with an expired promotion" do
      before do
        promotion.starts_at = 2.weeks.ago
        promotion.expires_at = 1.week.ago
        promotion.save
      end

      it "fails to apply" do
        post spree.api_order_coupon_codes_path(order), params: {coupon_code: "10off", order_token: order.guest_token}
        expect(response.status).to eq(422)
        expect(json_response["success"]).to be_blank
        expect(json_response["error"]).to eq("The coupon code is expired")
        expect(json_response["successful"]).to be false
        expect(json_response["status_code"]).to eq("coupon_code_expired")
      end
    end
  end
end
