# frozen_string_literal: true

require 'spec_helper'

describe 'orders', type: :feature do
  let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:complete) }
  let(:user) { create(:user) }

  before do
    order.update_attribute(:user_id, user.id)
    allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)
  end

  it "can visit an order" do
    # Regression test for current_user call on orders/show
    visit spree.order_path(order)
  end

  it "should display line item price" do
    # Regression test for https://github.com/spree/spree/issues/2772
    line_item = order.line_items.first
    line_item.target_shipment = create(:shipment)
    line_item.price = 19.00
    line_item.save!

    visit spree.order_path(order)

    # Tests view spree/shared/_order_details
    within 'td.price' do
      expect(page).to have_content "19.00"
    end
  end

  it "should have credit card info if paid with credit card" do
    create(:payment, order: order)
    visit spree.order_path(order)
    within '.payment-info' do
      expect(page).to have_content "Ending in 1111"
    end
  end

  it "should have payment method name visible if not paid with credit card" do
    create(:check_payment, order: order)
    visit spree.order_path(order)
    within '.payment-info' do
      expect(page).to have_content "Check"
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2282
  context "can support a credit card with blank information" do
    before do
      credit_card = create(:credit_card)
      credit_card.update_column(:cc_type, '')
      payment = order.payments.first
      payment.source = credit_card
      payment.save!
    end

    specify do
      visit spree.order_path(order)
      expect(find('.payment-info')).to have_no_css('img')
    end
  end

  it "should return the correct title when displaying a completed order" do
    visit spree.order_path(order)

    within '#order_summary' do
      expect(page).to have_content("#{I18n.t('spree.order')} #{order.number}")
    end
  end
end
