# frozen_string_literal: true

require "spec_helper"

describe "Tax categories", :js, type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

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

        click_on "Add Tax Category"

        expect(page).to have_content("Tax category was successfully created.")
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
end
