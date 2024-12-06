# frozen_string_literal: true

require 'spec_helper'

describe "Store Credit Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists store credit reasons and allows deleting them" do
    create(:store_credit_reason, name: "Default-store-credit-reason")

    visit "/admin/store_credit_reasons"
    expect(page).to have_content("Default-store-credit-reason")
    expect(page).to be_axe_clean

    select_row("Default-store-credit-reason")
    click_on "Delete"
    expect(page).to have_content("Store credit reasons were successfully removed.")
    expect(page).not_to have_content("Default-store-credit-reason")
    expect(Spree::StoreCreditReason.count).to eq(0)
    expect(page).to be_axe_clean
  end

  context "when creating a new store credit reason" do
    let(:query) { "?page=1&q%5Bname_cont%5D=new" }

    before do
      visit "/admin/store_credit_reasons#{query}"
      click_on "Add new"
      expect(page).to have_selector("dialog", wait: 5)
      expect(page).to have_content("New Store Credit Reason")
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog", wait: 5)
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new store credit reason, keeping page and q params" do
        fill_in "Name", with: "New Reason"

        click_on "Add Store Credit Reason"

        expect(page).to have_content("Store credit reason was successfully created.")
        expect(Spree::StoreCreditReason.find_by(name: "New Reason")).to be_present
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      it "fails to create a new store credit reason, keeping page and q params" do
        click_on "Add Store Credit Reason"

        expect(page).to have_content("can't be blank")
        expect(page.current_url).to include(query)
      end
    end
  end

  context "when editing an existing store credit reason" do
    let(:query) { "?page=1&q%5Bname_cont%5D=customer" }

    before do
      Spree::StoreCreditReason.create(name: "New Customer Reward")
      visit "/admin/store_credit_reasons#{query}"
      find_row("New Customer Reward").click
      expect(page).to have_selector("dialog", wait: 5)
      expect(page).to have_content("Edit Store Credit Reason")
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog", wait: 5)
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing store credit reason" do
      fill_in "Name", with: "Customer complaint"

      click_on "Update Store Credit Reason"
      expect(page).to have_content("Store credit reason was successfully updated.")
      expect(page).to have_content("Customer complaint")
      expect(page).not_to have_content("New Customer Reward")
      expect(Spree::StoreCreditReason.find_by(name: "Customer complaint")).to be_present
      expect(page.current_url).to include(query)
    end
  end
end
