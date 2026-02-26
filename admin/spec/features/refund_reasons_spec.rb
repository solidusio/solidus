# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/bulk_delete_resources"

describe "Refund Reasons", type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists refund reasons and allows deleting them", :js do
    create(:refund_reason, name: "Default-refund-reason")

    visit "/admin/refund_reasons"
    expect(page).to have_content("Default-refund-reason")
    expect(page).to be_axe_clean

    select_row("Default-refund-reason")
    click_on "Delete"
    expect(page).to have_content("Refund reasons were successfully removed.")
    expect(page).not_to have_content("Default-refund-reason")
    expect(Spree::RefundReason.count).to eq(0)
    expect(page).to be_axe_clean
  end

  context "when creating a new refund reason" do
    let(:query) { "?page=1&q%5Bname_or_code_cont%5D=Ret" }

    before do
      visit "/admin/refund_reasons/#{query}"
      click_on "Add new"
      expect(page).to have_css("dialog")
      expect(page).to have_content("New Refund Reason")
    end

    it "is accessible", :js do
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params", :js do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new refund reason, keeping page and q params" do
        fill_in "Name", with: "Return process"
        uncheck "Active"

        click_on "Add Refund Reason"

        expect(page).to have_content("Refund reason was successfully created.")
        click_on "Return process"
        expect(checkbox("Active")).not_to be_checked
        expect(Spree::RefundReason.find_by(name: "Return process")).to be_present
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      it "fails to create a new refund reason, keeping page and q params" do
        click_on "Add Refund Reason"

        expect(page).to have_content "can't be blank"
        expect(page.current_url).to include(query)
      end
    end
  end

  context "when editing an existing refund reason" do
    let(:query) { "?page=1&q%5Bname_or_code_cont%5D=Ret" }

    before do
      Spree::RefundReason.create(name: "Return process", active: false)
      visit "/admin/refund_reasons#{query}"
      click_on "Return process"
      expect(page).to have_css("dialog")
      expect(page).to have_content("Edit Refund Reason")
    end

    it "is accessible", :js do
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params", :js do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing refund reason", :js do
      fill_in "Name", with: "Customer complaint"
      check "Active"
      click_on "Update Refund Reason"

      expect(page.current_url).to include(query)
      expect(page).to have_content("Refund reason was successfully updated.")
      expect(page).to have_content("No Refund Reasons found") # search query still applied, filters out updated name
      clear_search

      expect(page).to have_content("Customer complaint")
      expect(page).not_to have_content("Return process")

      click_on "Customer complaint"
      expect(checkbox("Active")).to be_checked
      expect(Spree::RefundReason.find_by(name: "Customer complaint")).to be_present
    end
  end
end
