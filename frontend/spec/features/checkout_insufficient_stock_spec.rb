# frozen_string_literal: true

require 'spec_helper'

describe "Checkout confirm page", type: :feature do
  include_context 'checkout setup'

  context 'when there is not enough stock at the default stock location' do
    context "when the product is not backorderable" do
      let(:user) { create(:user) }

      let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment) }
      let(:order_product) { order.products.first }
      let(:order_stock_item) { order_product.stock_items.first }

      before do
        order_stock_item.update! backorderable: false

        allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
        allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
        allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)
      end

      context 'when there are not other backorderable stock locations' do
        before { visit spree.checkout_state_path(:confirm) }

        it 'redirects to cart page and shows an unavailable product message' do
          expect(page).to have_content "#{order_product.name} became unavailable"
          expect(page).to have_current_path spree.cart_path
        end
      end

      context 'when there is another backorderable stock location' do
        before do
          create :stock_location, backorderable_default: true, default: false
          visit spree.checkout_state_path(:confirm)
        end

        it 'redirects to cart page and shows an unavailable product message' do
          expect(page).to have_content "#{order_product.name} became unavailable"
          expect(page).to have_current_path spree.cart_path
        end
      end
    end
  end
end
