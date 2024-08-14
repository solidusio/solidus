# frozen_string_literal: true

require 'spec_helper'

describe "Roles", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists roles and allows deleting them" do
    create(:role, name: "Customer Role" )
    Spree::Role.find_or_create_by(name: 'admin')

    visit "/admin/roles"
    expect(page).to have_content("Users and Roles")
    expect(page).to have_content("Customer Role")
    expect(page).to have_content("admin")
    click_on "Admin"
    expect(page).to have_content("admin")
    expect(page).not_to have_content("Customer Role")
    click_on "All"
    expect(page).to have_content("Customer Role")
    expect(page).to have_content("admin")

    expect(page).to be_axe_clean

    select_row("Customer Role")
    click_on "Delete"
    expect(page).to have_content("Roles were successfully removed.")
    expect(page).not_to have_content("Customer Role")
    expect(Spree::Role.count).to eq(1)
  end

  context "when creating a role" do
    let(:query) { "?page=1&q%5Bname_cont%5D=new" }

    before do
      visit "/admin/roles#{query}"
      click_on "Add new"
      expect(page).to have_content("New Role")
      expect(page).to be_axe_clean
    end

    it "opens a modal" do
      expect(page).to have_selector("dialog")
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new role, keeping page and q params" do
        fill_in "Name", with: "Purchaser"

        click_on "Add Role"

        expect(page).to have_content("Role was successfully created.")
        expect(Spree::Role.find_by(name: "Purchaser")).to be_present
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      # @note: The only validation that Roles currently have is that names must
      #   be unique (but they can still be blank).
      before do
        create(:role, name: "Customer Role" )
      end

      it "fails to create a new role, keeping page and q params" do
        fill_in "Name", with: "Customer Role"
        click_on "Add Role"

        expect(page).to have_content("has already been taken")
        expect(page.current_url).to include(query)
      end
    end
  end
end
