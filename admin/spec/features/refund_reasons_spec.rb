# frozen_string_literal: true

require 'spec_helper'

describe "Refund Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists refund reasons and allows deleting them" do
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
    let(:query) { "?page=1&q%5Bname_or_description_cont%5D=Ret" }

    before do
      visit "/admin/refund_reasons/#{query}"
      click_on "Add new"
      expect(page).to have_content("New Refund Reason")
      expect(page).to be_axe_clean
    end

    it "opens a modal" do
      expect(page).to have_selector("dialog")
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new refund reason, keeping page and q params" do
        fill_in "Name", with: "Return process"

        click_on "Add Refund Reason"

        expect(page).to have_content("Refund reason was successfully created.")
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
    let(:query) { "?page=1&q%5Bname_or_description_cont%5D=Ret" }

    before do
      Spree::RefundReason.create(name: "Return process")
      visit "/admin/refund_reasons#{query}"
      find_row("Return process").click
      expect(page).to have_content("Edit Refund Reason")
      expect(page).to be_axe_clean
    end

    it "opens a modal" do
      expect(page).to have_selector("dialog")
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing refund reason" do
      fill_in "Name", with: "Customer complaint"

      click_on "Update Refund Reason"
      expect(page).to have_content("Refund reason was successfully updated.")
      expect(page).to have_content("Customer complaint")
      expect(page).not_to have_content("Return process")
      expect(Spree::RefundReason.find_by(name: "Customer complaint")).to be_present
      expect(page.current_url).to include(query)
    end
  end
end
