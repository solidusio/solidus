# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Free shipping promotions', type: :system, js: true do
  include  SolidusStarterFrontend::System::CheckoutHelpers

  let!(:store) { create(:store) }
  let!(:country) { create(:country, name: "United States of America", states_required: true) }
  let!(:state) { create(:state, name: "Alabama", country: country) }
  let!(:zone) { create(:zone) }
  let!(:shipping_method) do
    sm = create(:shipping_method)
    sm.calculator.preferred_amount = 10
    sm.calculator.save
    sm
  end

  let!(:payment_method) { create(:check_payment_method) }
  let!(:product) { create(:product, name: "Solidus mug set", price: 20) }
  let!(:promotion) do
    create(
      :promotion,
      apply_automatically: true,
      promotion_actions: [Spree::Promotion::Actions::FreeShipping.new],
      name: "Free Shipping",
      starts_at: 1.day.ago,
      expires_at: 1.day.from_now,
    )
  end

  context "free shipping promotion automatically applied" do
    before do
      visit products_path
      click_link "Solidus mug set"
      click_button "add-to-cart-button"
      checkout_as_guest
      fill_in "order_email", with: "spree@example.com"
      fill_in "Name", with: "John Smith"
      fill_in 'Street Address:', with: '1 John Street'
      fill_in "City", with: "City of John"
      fill_in "Zip", with: "01337"
      select country.name, from: "Country"
      select state.name, from: "order[bill_address_attributes][state_id]"
      fill_in "Phone", with: "555-555-5555"

      # To shipping method screen
      click_button "Save and Continue"
      # To payment screen
      click_button "Save and Continue"
    end

    # Regression test for https://github.com/spree/spree/issues/4428
    it "applies the free shipping promotion" do
      within("#checkout-summary") do
        expect(page).to have_content("Shipping total: $10.00", normalize_ws: true)
        expect(page).to have_content("Promotion (Free Shipping): -$10.00", normalize_ws: true)
      end
    end
  end
end
