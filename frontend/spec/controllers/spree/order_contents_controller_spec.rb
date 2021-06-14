# frozen_string_literal: true

require 'spec_helper'

describe Spree::OrderContentsController, type: :controller do
  let!(:store) { create(:store) }
  let(:user) { create(:user) }

  before do
    allow(controller).to receive_messages(try_spree_current_user: user)
  end

  context "#create" do
    it "should create a new an Order when none specified" do
      variant = create(:variant)

      post :create, params: { variant_id: variant.id }

      expect(response).to be_redirect
      expect(cookies.signed[:guest_token]).not_to be_blank
      order_by_token = Spree::Order.find_by(guest_token: cookies.signed[:guest_token])
      assigned_order = assigns[:order]
      expect(assigned_order).to eq order_by_token
      expect(assigned_order).to be_persisted
    end

    it "should create an Order with a LineItem" do
      variant = create(:variant)
      user_order_before_count = user.orders.count

      post :create, params: { variant_id: variant.id, quantity: 5 }

      expect(user.orders.count).to eq(user_order_before_count + 1)
      order = user.orders.last
      expect(response).to redirect_to spree.cart_path
      expect(order.line_items.size).to eq(1)
      line_item = order.line_items.first
      expect(line_item.variant_id).to eq(variant.id)
      expect(line_item.quantity).to eq(5)
    end

    it "shows an error when adding a LineItem fails" do
      variant = create(:variant)

      request.env["HTTP_REFERER"] = spree.root_path
      allow_any_instance_of(Spree::LineItem).to(
        receive(:valid?).and_return(false)
      )
      allow_any_instance_of(Spree::LineItem).to(
        receive_message_chain(:errors, :full_messages).
          and_return(["Adding lineitem to order failed"])
      )

      post :create, params: { variant_id: variant.id, quantity: 5 }

      expect(response).to redirect_to(spree.root_path)
      expect(flash[:error]).to eq("Adding lineitem to order failed")
    end

    context "when the Variant's" do
      context "quantity is invalid/unreasonable" do
        it "shows an error" do
          variant = create(:variant)
          request.env["HTTP_REFERER"] = spree.root_path

          post(
            :create,
            params: { variant_id: variant.id, quantity: -1 }
          )

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq(
            I18n.t('spree.please_enter_reasonable_quantity')
          )
        end
      end

      context "quantity is an empty string" do
        it "should create order with a LineItem of a quantity of 1" do
          variant = create(:variant)
          user_order_before_count = user.orders.count

          post :create, params: { variant_id: variant.id, quantity: '' }

          expect(user.orders.count).to eq(user_order_before_count + 1)
          order = Spree::Order.last
          expect(response).to redirect_to spree.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(1)
        end
      end

      context "quantity is nil" do
        it "should create order with a LineItem of a quantity of 1" do
          variant = create(:variant)
          user_order_before_count = user.orders.count

          post :create, params: { variant_id: variant.id, quantity: nil }

          expect(user.orders.count).to eq(user_order_before_count + 1)
          order = Spree::Order.last
          expect(response).to redirect_to spree.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(1)
        end
      end
    end
  end
end
