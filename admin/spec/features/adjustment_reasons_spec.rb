# frozen_string_literal: true

require 'spec_helper'
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

describe "Adjustment Reasons", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists adjustment reasons and allows deleting them", :js do
    create(:adjustment_reason, name: "Default-adjustment-reason")

    visit "/admin/adjustment_reasons"
    expect(page).to have_content("Default-adjustment-reason")
    expect(page).to be_axe_clean

    select_row("Default-adjustment-reason")
    click_on "Delete"
    expect(page).to have_content("Adjustment reasons were successfully removed.")
    expect(page).not_to have_content("Default-adjustment-reason")
    expect(Spree::AdjustmentReason.count).to eq(0)
    expect(page).to be_axe_clean
  end

  context "when creating a new adjustment reason" do
    let(:query) { "?page=1&q%5Bname_or_code_cont%5D=new" }

    before do
      visit "/admin/adjustment_reasons#{query}"
      click_on "Add new"
      expect(page).to have_selector("dialog")
      expect(page).to have_content("New Adjustment Reason")
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
      it "successfully creates a new adjustment reason, keeping page and q params" do
        fill_in "Name", with: "New Reason"
        fill_in "Code", with: "1234"
        page.uncheck "adjustment_reason[active]"

        click_on "Add Adjustment Reason"

        expect(page).to have_content("Adjustment reason was successfully created.")
        expect(Spree::AdjustmentReason.find_by(name: "New Reason")).to be_present
        expect(Spree::AdjustmentReason.find_by(name: "New Reason").active).to be_falsey
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      it "fails to create a new adjustment reason, keeping page and q params" do
        click_on "Add Adjustment Reason"

        expect(page).to have_content("can't be blank").twice
        expect(page.current_url).to include(query)
      end
    end
  end

  context "when editing an existing adjustment reason" do
    let(:query) { "?page=1&q%5Bname_or_code_cont%5D=reason" }

    before do
      Spree::AdjustmentReason.create(name: "Good Reason", code: 5999)
      visit "/admin/adjustment_reasons#{query}"
      click_on "Good Reason"
      expect(page).to have_selector("dialog")
      expect(page).to have_content("Edit Adjustment Reason")
    end

    it "is accessible", :js do
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params", :js do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing adjustment reason" do
      fill_in "Name", with: "Better Reason"
      page.uncheck "adjustment_reason[active]"

      click_on "Update Adjustment Reason"
      expect(page).to have_content("Adjustment reason was successfully updated.")
      expect(page).to have_content("Better Reason")
      expect(page).not_to have_content("Good Reason")
      expect(Spree::AdjustmentReason.find_by(name: "Better Reason")).to be_present
      expect(Spree::AdjustmentReason.find_by(name: "Better Reason").active).to be_falsey
      expect(page.current_url).to include(query)
    end
  end
end
