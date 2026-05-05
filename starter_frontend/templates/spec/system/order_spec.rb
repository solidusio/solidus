# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'orders', type: :system do
  let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:complete) }
  let(:user) { create(:user) }

  before do
    order.update_attribute(:user_id, user.id)
    allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)
  end

  it "can visit an order" do
    # Regression test for current_user call on orders/show
    visit order_path(order)
  end

  it "should display line item price" do
    # Regression test for https://github.com/spree/spree/issues/2772
    line_item = order.line_items.first
    line_item.target_shipment = create(:shipment)
    line_item.price = 19.00
    line_item.save!

    visit order_path(order)

    # Tests view spree/shared/_order_details
    within '.order-item__price-single' do
      expect(page).to have_content "19.00"
    end
  end

  it "should have credit card info if paid with credit card" do
    create(:payment, order: order)
    visit order_path(order)
    within '.payment-info' do
      expect(page).to have_content "Ending in 1111"
    end
  end

  it "should have payment method name visible if not paid with credit card" do
    create(:check_payment, order: order)
    visit order_path(order)
    within '.payment-info' do
      expect(page).to have_content "Check"
    end
  end

  it "should return the correct title when displaying a completed order" do
    visit order_path(order)

    within 'h1' do
      expect(page).to have_content("#{I18n.t('spree.order')} #{order.number}")
    end
  end
end
