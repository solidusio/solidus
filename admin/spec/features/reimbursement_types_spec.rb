# frozen_string_literal: true

require "spec_helper"

describe "Reimbursement Types", :js, type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists Reimbursement Types and allows deleting them" do
    create(:reimbursement_type, name: "Default-reimbursement-type")

    visit "/admin/reimbursement_types"
    expect(page).to have_content("Default-reimbursement-type")
    expect(page).to be_axe_clean

    select_row("Default-reimbursement-type")
    click_on "Delete"
    expect(page).to have_content("Reimbursement types were successfully removed.")
    expect(page).not_to have_content("Default-reimbursement-type")
    expect(Spree::ReimbursementType.count).to eq(0)
    expect(page).to be_axe_clean
  end

  context "when creating a new reimbursement type" do
    let(:filtered_url) { "/admin/reimbursement_types?page=1&q%5Bname_cont%5D=new" }

    it "closing the modal keeps query params" do
      visit filtered_url
      click_on "Add new"
      expect(page).to have_selector("dialog")
      expect(page).to have_content("New Reimbursement Type")

      expect(page).to be_axe_clean

      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to end_with(filtered_url)
    end

    context "with valid data" do
      it "successfully creates a new reimbursement type, keeping page and q params" do
        visit filtered_url
        click_on "Add new"
        expect(page).to have_selector("dialog")
        expect(page).to have_content("New Reimbursement Type")

        expect(page).to be_axe_clean

        fill_in "Name", with: "New Reason"
        page.uncheck "reimbursement_type[active]"

        click_on "Add Reimbursement Type"

        expect(page).to have_content("Reimbursement type was successfully created.")
        expect(Spree::ReimbursementType.find_by(name: "New Reason")).to be_present
        expect(Spree::ReimbursementType.find_by(name: "New Reason").active).to be_falsey
        expect(page.current_url).to end_with(filtered_url)
      end
    end

    context "with invalid data" do
      it "fails to create a new reimbursement type, keeping page and q params" do
        visit filtered_url
        click_on "Add new"
        expect(page).to have_selector("dialog")
        expect(page).to have_content("New Reimbursement Type")

        expect(page).to be_axe_clean

        click_on "Add Reimbursement Type"

        expect(page).to have_content("can't be blank")
        expect(page.current_url).to end_with(filtered_url)
      end
    end
  end

  context "when editing an existing reimbursement type" do
    let(:filtered_url) { "/admin/reimbursement_types?page=1&q%5Bname_cont%5D=reason" }

    before do
      Spree::ReimbursementType.create(name: "Good Reason")
    end

    it "closing the modal keeps query params" do
      visit filtered_url
      click_on "Good Reason"
      expect(page).to have_selector("dialog")
      expect(page).to have_content("Edit Reimbursement Type")

      expect(page).to be_axe_clean

      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to end_with(filtered_url)
    end

    it "successfully updates the existing reimbursement type" do
      visit filtered_url
      click_on "Good Reason"
      expect(page).to have_selector("dialog")
      expect(page).to have_content("Edit Reimbursement Type")

      expect(page).to be_axe_clean

      fill_in "Name", with: "Better Reason"
      page.uncheck "reimbursement_type[active]"

      click_on "Update Reimbursement Type"
      expect(page).to have_content("Reimbursement type was successfully updated.")
      expect(page).to have_content("Better Reason")
      expect(page).not_to have_content("Good Reason")
      expect(Spree::ReimbursementType.find_by(name: "Better Reason")).to be_present
      expect(Spree::ReimbursementType.find_by(name: "Better Reason").active).to be_falsey
      expect(page.current_url).to end_with(filtered_url)
    end
  end
end
