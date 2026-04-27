# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'First Order promotion', type: :system do
  include  SolidusStarterFrontend::System::CheckoutHelpers

  let!(:promotion) do
    FactoryBot.create(
      :promotion_with_first_order_rule,
      :with_order_adjustment,
      code: "FIRSTONEFREE",
      per_code_usage_limit: 10
    )
  end

  before do
    create(:store)
    product = FactoryBot.create(:product)
    visit products_path
    click_link product.name
    click_button "Add To Cart"
  end

  it 'Adding first order promotion to cart and checking out as guest' do
    fill_in "Coupon code", with: "FIRSTONEFREE"
    click_button "Apply Code"
    expect(page).to have_content("The coupon code was successfully applied to your order")

    within("#cart_adjustments") do
      expect(page).to have_content("-$10.00")
    end
  end

  it 'Trying to reuse first order promotion', js: true do
    previous_user = FactoryBot.create(
      :user,
      email: "sam@tom.com"
    )
    _previous_order = create(:completed_order_with_totals, user: previous_user)
    fill_in "Coupon code", with: "FIRSTONEFREE"
    click_button "Apply Code"
    expect(page).to have_content("The coupon code was successfully applied to your order")
    checkout_as_guest
    fill_in "Customer email", with: "sam@tom.com"
    fill_in_address
    click_on "Save and Continue"
    expect(page).to_not have_content("#summary-order-charges")
  end

  def fill_in_address
    address = "order_bill_address_attributes"
    fill_in "#{address}_name", with: "Ryan Bigg"
    fill_in "#{address}_address1", with: "143 Swan Street"
    fill_in "#{address}_city", with: "Richmond"
    select "United States of America", from: "#{address}_country_id"
    fill_in "#{address}_zipcode", with: "12345"
    fill_in "#{address}_phone", with: "(555) 555-5555"
  end
end
