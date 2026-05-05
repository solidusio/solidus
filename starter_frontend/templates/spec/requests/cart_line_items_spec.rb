# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Cart Line Items', type: :request do
  let!(:store) { create(:store) }
  let(:variant) { create(:variant) }

  context "#create" do
    it "creates a new order when none specified" do
      expect do
        post cart_line_items_path, params: { variant_id: variant.id }
      end.to change(Spree::Order, :count).by(1)

      expect(response).to be_redirect
      expect(response.cookies['guest_token']).not_to be_blank

      jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
      order_by_token = Spree::Order.find_by(guest_token: jar.signed[:guest_token])

      expect(order_by_token).to be_persisted
    end

    context "when variant" do
      let(:user) { create(:user) }

      it "handles population", with_signed_in_user: true do
        expect do
          post cart_line_items_path, params: { variant_id: variant.id, quantity: 5 }
        end.to change { user.orders.count }.by(1)
        expect(response).to redirect_to cart_path
        order = user.orders.first
        expect(order.line_items.size).to eq(1)
        line_item = order.line_items.first
        expect(line_item.variant_id).to eq(variant.id)
        expect(line_item.quantity).to eq(5)
      end

      context 'when fails to populate' do
        it "shows an error when quantity is invalid" do
          post(
            cart_line_items_path,
            headers: { 'HTTP_REFERER' => root_path },
            params: { variant_id: variant.id, quantity: -1 }
          )

          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(
            I18n.t('spree.please_enter_reasonable_quantity')
          )
        end
      end

      context "when quantity is empty string" do
        it "populates order with 1 of given variant" do
          expect do
            post cart_line_items_path, params: { variant_id: variant.id, quantity: '' }
          end.to change { Spree::Order.count }.by(1)
          order = Spree::Order.last
          expect(response).to redirect_to cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(1)
        end
      end

      context "when quantity is nil" do
        it "populates order with 1 of given variant" do
          expect do
            post cart_line_items_path, params: { variant_id: variant.id, quantity: nil }
          end.to change { Spree::Order.count }.by(1)
          order = Spree::Order.last
          expect(response).to redirect_to cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(1)
        end
      end
    end
  end
end
