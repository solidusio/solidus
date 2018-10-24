# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::CouponCodesController, type: :request do
    before do
      stub_authentication!
    end

    describe '#create' do
      let(:promo) { create(:promotion_with_item_adjustment, code: 'night_melody') }
      let(:promo_code) { promo.codes.first }

      context 'when successful' do
        let(:order) { create(:order_with_line_items) }

        it 'applies the coupon' do
          post spree.api_order_coupon_codes_path(order), params: { coupon_code: promo_code.value }

          expect(response.status).to eq(200)
          expect(order.reload.promotions).to eq([promo])
          expect(json_response).to eq({
            "success" => I18n.t('spree.coupon_code_applied'),
            "error" => nil,
            "successful" => true,
            "status_code" => "coupon_code_applied"
          })
        end
      end

      context 'when unsuccessful' do
        let(:order) { create(:order) }

        it 'returns an error' do
          post spree.api_order_coupon_codes_path(order), params: { coupon_code: promo_code.value }

          expect(response.status).to eq(422)
          expect(order.reload.promotions).to eq([])
          expect(json_response).to eq({
            "success" => nil,
            "error" => I18n.t('spree.coupon_code_unknown_error'),
            "successful" => false,
            "status_code" => "coupon_code_unknown_error"
          })
        end
      end
    end
  end
end
