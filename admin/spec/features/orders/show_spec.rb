# frozen_string_literal: true

require 'spec_helper'

describe "Order", :js, type: :feature do
  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
    sign_in create(:admin_user, email: 'admin@example.com')
  end

  it "allows detaching a customer from an order" do
    order = create(:order, number: "R123456789", user: create(:user))

    visit "/admin/orders/R123456789"

    open_customer_menu
    click_on "Remove customer"

    expect(page).to have_content("Customer was removed successfully")
    open_customer_menu
    expect(page).not_to have_content("Remove customer")
    expect(order.reload.user).to be_nil
    expect(page).to be_axe_clean
  end

  it "allows changing the order email" do
    create(:order, number: "R123456789", total: 19.99)

    visit "/admin/orders/R123456789/edit"

    expect(page).to have_content("Order R123456789")
    open_customer_menu
    click_on "Edit order email"
    within("dialog") do
      fill_in "Customer Email", with: "a@b.c"
      click_on "Save"
    end
    expect(page).to have_content("Order was updated successfully")
    expect(page).to have_content("Order contact email a@b.c", normalize_ws: true)
    expect(page).to be_axe_clean
  end

  it "allows setting and changing the addresses" do
    create(:order, number: "R123456789", total: 19.99)
    create(:state, name: "Ontario", country: create(:country, iso: "CA"))
    create(:state, name: "Bahia", country: create(:country, iso: "BR"))

    visit "/admin/orders/R123456789/edit"

    expect(page).to have_content("Order R123456789")
    open_customer_menu
    click_on "Edit billing address"
    expect(page).to have_css("dialog", wait: 5)

    within("dialog") do
      fill_in "Name", with: "John Doe"
      fill_in "Street Address", with: "1 John Doe Street"
      fill_in "Street Address (cont'd)", with: "Apartment 2"
      fill_in "City", with: "John Doe City"
      fill_in "Zip Code", with: "12345"
      fill_in "Phone", with: "555-555-5555"
      solidus_select "Canada", from: "Country"
      solidus_select "Ontario", from: "State"
      click_on "Save"
    end

    expect(page).to have_content("The address has been successfully updated.")
    expect(page).to have_content("John Doe")
    expect(page).to have_content("1 John Doe Street")
    expect(page).to have_content("Apartment 2")
    expect(page).to have_content("John Doe City")
    expect(page).to have_content("12345")
    expect(page).to have_content("Canada")
    expect(page).to have_content("Ontario")
    expect(page).to have_content("555-555-5555")

    open_customer_menu
    click_on "Edit shipping address"
    expect(page).to have_css("dialog", wait: 5)

    within("dialog") do
      fill_in "Name", with: "Jane Doe"
      fill_in "Street Address", with: "1 Jane Doe Street"
      fill_in "Street Address (cont'd)", with: "Apartment 3"
      fill_in "City", with: "Jane Doe City"
      fill_in "Zip Code", with: "54321"
      fill_in "Phone", with: "555-555-5555"
      solidus_select "Brazil", from: "Country"
      solidus_select "Bahia", from: "State"
      click_on "Save"
    end

    expect(page).to have_content("The address has been successfully updated.")
    expect(page).to have_content("Jane Doe")
    expect(page).to have_content("1 Jane Doe Street")
    expect(page).to have_content("Apartment 3")
    expect(page).to have_content("Jane Doe City")
    expect(page).to have_content("54321")
    expect(page).to have_content("Brazil")
    expect(page).to have_content("Bahia")
    expect(page).to have_content("555-555-5555")
  end

  context "in cart state" do
    it "allows managing the cart" do
      create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)
      create(:product, name: "Just another product", slug: 'just-another-prod', price: 29.99)
      create(:order, number: "R123456789", total: 19.99, state: "cart")

      visit "/admin/orders/R123456789/edit"
      expect(page).to have_current_path("/admin/orders/R123456789")

      expect(page).to have_content("Order R123456789")

      search_field = find("[data-#{SolidusAdmin::UI::Forms::Search::Component.stimulus_id}-target='searchField']")
      search_field.set "another"

      expect(page).not_to have_content("Just a product")
      expect(page).to have_content("Just another product")

      expect(Spree::Order.last.line_items.count).to eq(0)

      find("[aria-selected]", text: "Just another product").click
      expect(page).to have_content("Variant added to cart successfully", wait: 5)

      expect(Spree::Order.last.line_items.count).to eq(1)
      expect(Spree::Order.last.line_items.last.quantity).to eq(1)

      fill_in "line_item[quantity]", with: 4
      expect(page).to have_content("Quantity updated successfully", wait: 5)

      expect(Spree::Order.last.line_items.last.quantity).to eq(4)

      accept_confirm("Are you sure?") { click_on "Delete" }
      expect(page).to have_content("Line item removed successfully", wait: 5)

      expect(Spree::Order.last.line_items.count).to eq(0)
      expect(page).to be_axe_clean
    end
  end

  describe 'summary panel' do
    shared_examples_for 'summary panel' do
      let!(:order) { create(:order, number: "R123456789", total: 4.99, currency:) }
      let(:currency) { 'USD' }

      it 'displays order summary correctly' do
        visit "/admin/orders/R123456789"

        expect(page).to have_content("Summary")
        expect(page).to have_content(/Subtotal\s#{Regexp.escape(order.display_item_total.to_s)}/)
        expect(page).to have_content(/Taxes\s#{Regexp.escape(order.display_additional_tax_total.to_s)}/)
        expect(page).to have_content(/Shipping\s#{Regexp.escape(order.display_shipment_total.to_s)}/)
        expect(page).to have_content(/Add Promo Code\s#{Regexp.escape(order.display_promo_total.to_s)}/)
        expect(page).to have_content(/Adjustments\s#{Regexp.escape(order.display_adjustment_total.to_s)}/)
        expect(page).to have_content(/Total\s#{Regexp.escape(order.display_total.to_s)}/)
      end
    end

    include_examples "summary panel"

    context 'with different currency' do
      include_examples "summary panel" do
        let(:currency) { 'EUR' }
      end
    end
  end

  private

  def open_customer_menu
    find("summary[title='More']").click
  end
end
