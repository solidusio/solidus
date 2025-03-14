# frozen_string_literal: true

require 'spec_helper'
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

describe "Tax categories", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists tax categories and allows deleting them" do
    create(:tax_category, name: "Clothing")
    create(:tax_category, name: "Food")

    visit "/admin/tax_categories"
    expect(page).to have_content("Clothing")
    expect(page).to have_content("Food")
    expect(page).to be_axe_clean

    select_row("Clothing")
    click_on "Delete"
    expect(page).to have_content("Tax categories were successfully removed.")
    expect(page).not_to have_content("Clothing")
    expect(Spree::TaxCategory.count).to eq(1)
    expect(page).to be_axe_clean
  end

  include_examples 'feature: bulk delete resources' do
    let(:resource_factory) { :tax_category }
    let(:index_path) { "/admin/tax_categories" }
  end

  context "when creating a new tax category" do
    let(:query) { "?page=1&q%5Bname_or_description_cont%5D=Cloth" }

    before do
      visit "/admin/tax_categories#{query}"
      click_on "Add new"
      expect(page).to have_selector("dialog")
      expect(page).to have_content("New Tax Category")
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new tax category, keeping page and q params" do
        fill_in "Name", with: "Clothing"
        check "Default"

        click_on "Add Tax Category"

        expect(page).to have_content("Tax category was successfully created.")
        click_on "Clothing"
        expect(checkbox("Default")).to be_checked
        expect(Spree::TaxCategory.find_by(name: "Clothing")).to be_present
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      it "fails to create a new tax category, keeping page and q params" do
        click_on "Add Tax Category"

        expect(page).to have_content "can't be blank"
        expect(page.current_url).to include(query)
      end
    end
  end

  context "when editing an existing tax category" do
    let(:query) { "?page=1&q%5Bname_or_description_cont%5D=Cloth" }

    before do
      Spree::TaxCategory.create(name: "Clothing", is_default: true)
      visit "/admin/tax_categories#{query}"
      click_on "Clothing"
      expect(page).to have_css("dialog")
      expect(page).to have_content("Edit Tax Category")
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing tax category" do
      fill_in "Name", with: "Other"
      uncheck "Default"
      click_on "Update Tax Category"

      expect(page.current_url).to include(query)
      expect(page).to have_content("Tax category was successfully updated.")
      expect(page).to have_content("No Tax Categories found") # search query still applied, filters out updated name
      clear_search

      expect(page).to have_content("Other")
      expect(page).not_to have_content("Clothing")
      click_on "Other"
      expect(checkbox("Default")).not_to be_checked
    end
  end
end
