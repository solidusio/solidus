# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe "Address", type: :system do
  include SolidusStarterFrontend::System::CheckoutHelpers

  include_context "featured products"

  let!(:product) { create(:product, name: "Solidus mug set") }
  let!(:order) { create(:order_with_totals, state: "cart") }

  before do
    visit products_path

    click_link "Solidus mug set"
    click_button "add-to-cart-button"

    address = "order_bill_address_attributes"
    @state_select_css = "##{address}_state_id"
    @state_name_css = "##{address}_state_name"
  end

  context "country requires state", js: true do
    let!(:has_states_country) { create(:country, name: "Canada", states_required: true, iso: "CA") }
    let!(:no_states_country) { create(:country, name: "United Kingdom", states_required: true, iso: "GB") }
    let!(:states_not_required_country) { create(:country, name: "France", states_required: false, iso: "FR") }

    before {
      stub_spree_preferences(default_country_iso: has_states_country.iso)

      create(:state, name: "Ontario", country: has_states_country)
    }

    scenario "switching between countries with and without states and states required" do
      checkout_as_guest

      within("#billing") do
        select "United Kingdom", from: "Country"

        expect(page).to have_css("#{@state_name_css}.required")
        expect(page).to have_no_css(@state_select_css)

        page.find(@state_name_css).set("Devon")

        select "Canada", from: "Country"

        expect(page).to have_css("#{@state_select_css}.required")
        expect(page).to have_no_css(@state_name_css)

        select "France", from: "Country"

        expect(page).to have_css("#{@state_select_css}[disabled]", visible: false)
        expect(page).to have_no_css(@state_name_css)
      end
    end
  end
end
