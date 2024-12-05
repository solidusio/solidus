# frozen_string_literal: true

require 'spec_helper'

describe "Return Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists Return Reasons and allows deleting them" do
    create(:return_reason, name: "Default-return-reason")

    visit "/admin/return_reasons"
    expect(page).to have_content("Default-return-reason")
    expect(page).to be_axe_clean

    select_row("Default-return-reason")
    click_on "Delete"
    expect(page).to have_content("Return reasons were successfully removed.")
    expect(page).not_to have_content("Default-return-reason")
    expect(Spree::ReturnReason.count).to eq(0)
    expect(page).to be_axe_clean
  end

  context "when creating a new return reason" do
    let(:query) { "?page=1&q%5Bname_cont%5D=new" }

    before do
      visit "/admin/return_reasons#{query}"
      click_on "Add new"
      expect(page).to have_selector("dialog", wait: 5)
      expect(page).to have_content("New Return Reason")
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new return reason, keeping page and q params" do
        fill_in "Name", with: "New Reason"
        page.uncheck "return_reason[active]"

        click_on "Add Return Reason"

        expect(page).to have_content("Return reason was successfully created.")
        expect(Spree::ReturnReason.find_by(name: "New Reason")).to be_present
        expect(Spree::ReturnReason.find_by(name: "New Reason").active).to be_falsey
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      it "fails to create a new return reason, keeping page and q params" do
        click_on "Add Return Reason"

        expect(page).to have_content("can't be blank")
        expect(page.current_url).to include(query)
      end
    end
  end

  context "when editing an existing return reason" do
    let(:query) { "?page=1&q%5Bname_cont%5D=reason" }

    before do
      Spree::ReturnReason.create(name: "Good Reason")
      visit "/admin/return_reasons#{query}"
      find_row("Good Reason").click
      expect(page).to have_selector("dialog", wait: 5)
      expect(page).to have_content("Edit Return Reason")
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing return reason" do
      fill_in "Name", with: "Better Reason"
      page.uncheck "return_reason[active]"

      click_on "Update Return Reason"
      expect(page).to have_content("Return reason was successfully updated.")
      expect(page).to have_content("Better Reason")
      expect(page).not_to have_content("Good Reason")
      expect(Spree::ReturnReason.find_by(name: "Better Reason")).to be_present
      expect(Spree::ReturnReason.find_by(name: "Better Reason").active).to be_falsey
      expect(page.current_url).to include(query)
    end
  end
end
