# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Store credits', type: :feature do
  stub_authorization!

  let(:order) { FactoryBot.create(:completed_order_with_totals) }
  let(:payment) do
    FactoryBot.create(
      :store_credit_payment,
      order: order,
      amount: 20
    )
  end

  it "viewing a store credit payment" do
    visit spree.admin_order_payment_path(order, payment)

    expect(page).to have_content "Store Credit"
    expect(page).to have_content "Amount: $20.00"
  end
end
