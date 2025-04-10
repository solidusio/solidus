# frozen_string_literal: true

require 'spec_helper'
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

describe "Roles", type: :feature do
  before do
    sign_in create(:admin_user, email: 'admin@example.com')
  end

  let!(:settings_edit_permission) {
    Spree::PermissionSet.find_or_create_by!(
      name: "ConfigurationManagement",
      set: "Spree::PermissionSets::ConfigurationManagement",
      privilege: "management",
      category: "configuration"
    )
  }
  let!(:settings_view_permission) {
    Spree::PermissionSet.find_or_create_by!(
      name: "ConfigurationDisplay",
      set: "Spree::PermissionSets::ConfigurationDisplay",
      privilege: "display",
      category: "configuration"
    )
  }

  it "lists roles and allows deleting them", :js do
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
      expect(page).to have_selector("dialog", wait: 5)
      expect(page).to have_content("New Role")
    end

    it "is accessible", :js do
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params", :js do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog", wait: 5)
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new role, keeping page and q params" do
        fill_in "Name", with: "Purchaser"
        fill_in "Description", with: "A person who buys stuff"

        within("form.new_role") do
          expect(page).to have_content("Choose permissions")
          expect(page).to have_content("Settings")
          expect(page).to have_content("Edit")
          expect(page).to have_content("View")
          find('label', text: 'View').find('input[type=checkbox]').click
        end

        click_on "Add Role"

        expect(page).to have_content("Role was successfully created.")
        expect(Spree::Role.find_by(name: "Purchaser")).to be_present
        expect(Spree::Role.find_by(name: "Purchaser").permission_set_ids)
          .to contain_exactly(settings_view_permission.id)
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      context "with a non-unique name" do
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

      context "with no name" do
        it "fails to create a new role, keeping page and q params" do
          click_on "Add Role"

          expect(page).to have_content("can't be blank")
          expect(page.current_url).to include(query)
        end
      end
    end
  end

  context "when editing an existing role" do
    let(:query) { "?page=1&q%5Bname_cont%5D=er" }

    before do
      Spree::Role.create(name: "Reviewer", permission_sets: [settings_edit_permission])
      visit "/admin/roles#{query}"
      click_on "Reviewer"
      expect(page).to have_selector("dialog", wait: 5)
      expect(page).to have_content("Edit Role")
      expect(Spree::Role.find_by(name: "Reviewer").permission_set_ids)
      .to contain_exactly(settings_edit_permission.id)
    end

    it "is accessible", :js do
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params", :js do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog", wait: 5)
      expect(page.current_url).to include(query)
    end

    it "successfully updates the existing role" do
      fill_in "Name", with: "Publisher"
      fill_in "Description", with: "A person who publishes stuff"

      within("form.edit_role") do
        expect(page).to have_content("Choose permissions")
        expect(page).to have_content("Settings")
        expect(page).to have_content("Edit")
        expect(page).to have_content("View")
        expect(find('label', text: 'Edit').find('input[type=checkbox]').checked?).to eq(true)
        find('label', text: 'Edit').find('input[type=checkbox]').uncheck
        find('label', text: 'View').find('input[type=checkbox]').check
      end

      click_on "Update Role"
      expect(page).to have_content("Role was successfully updated.")
      expect(page).to have_content("Publisher")
      expect(page).to have_content("A person who publishes stuff")
      expect(page).not_to have_content("Reviewer")
      expect(Spree::Role.find_by(name: "Publisher")).to be_present
      expect(Spree::Role.find_by(name: "Publisher").permission_set_ids)
        .to contain_exactly(
          settings_view_permission.id,
        )
      expect(page.current_url).to include(query)
    end
  end
end
