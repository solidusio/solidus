# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Checkout confirm page submission', :js, type: :system do
  include_context 'checkout setup'

  context "when the product from the order is not backorderable but has enough stock quantity" do
    let(:user) { create(:user) }

    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment, user: user) }
    let(:order_product) { order.products.first }
    let(:order_stock_item) { order.line_items.first.variant.stock_items.first }

    before do
      order_stock_item.update! backorderable: false
      order_stock_item.set_count_on_hand(1)
      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
      allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)
    end

    context 'when there are not other backorderable stock locations' do
      context 'when the customer is on the confirm page and the availabilty drops to zero' do
        before do
          visit checkout_state_path(:confirm)
          order_stock_item.set_count_on_hand(0)
          order.line_items.first.variant.stock_items.reload
        end

        it 'redirects to cart page and shows an unavailable product message' do
          check 'Agree to Terms of Service'
          click_button "Place Order"
          expect(page).to have_content "#{order_product.name} became unavailable"
          expect(page).to have_current_path cart_path
        end
      end
    end

    context 'when there is another backorderable stock location' do
      before do
        create :stock_location, backorderable_default: true, default: false
      end

      context 'when the customer is on the confirm page and the availabilty drops to zero' do
        before do
          visit checkout_state_path(:confirm)
          order_stock_item.set_count_on_hand(0)
          order.line_items.first.variant.stock_items.reload
        end

        it "redirects to the address checkout page and shows an availability changed message" do
          check 'Agree to Terms of Service'
          click_button "Place Order"
          error_message = "Quantity selected of #{order_product.name} is not available. Still, items may be available from another stock location, please try again."
          expect(page).to have_content error_message
          expect(page).to have_current_path checkout_state_path(:address)
        end

        it "can still complete the order using the backorderable stock location by restarting the checkout" do
          check 'Agree to Terms of Service'
          click_button "Place Order"
          expect(page).to have_current_path checkout_state_path(:address)
          click_button "Save and Continue"
          expect(page).to have_current_path checkout_state_path(:delivery)
          click_button "Save and Continue"
          expect(page).to have_current_path checkout_state_path(:payment)
          click_button "Save and Continue"
          expect(page).to have_current_path checkout_state_path(:confirm)
          check 'Agree to Terms of Service'
          click_button "Place Order"
          expect(page).to have_content 'Your order has been processed successfully'
        end
      end
    end
  end
end
