# frozen_string_literal: true

require "spec_helper"

describe "Users", :js, type: :feature do
  let(:admin) { create(:admin_user, email: "admin@example.com") }

  before do
    sign_in admin
  end

  it "lists users and allows deleting them" do
    create(:user, email: "customer@example.com")
    create(:admin_user, email: "admin-2@example.com")
    create(:user, :with_orders, email: "customer-with-order@example.com")

    visit "/admin/users"
    expect(page).to have_content("Last active")
    expect(page).to have_content("Never")

    expect(page).to have_content("customer@example.com")
    expect(page).to have_content("admin-2@example.com")
    expect(page).to have_content("customer-with-order@example.com")
    click_on "Customers"
    expect(page).to have_content("Users and Roles")
    expect(page).to have_content("customer@example.com")
    expect(page).not_to have_content("admin-2@example.com")
    click_on "Admins"
    expect(page).to have_content("admin-2@example.com")
    expect(page).not_to have_content("customer@example.com")
    click_on "With Orders"
    expect(page).to have_content("customer-with-order@example.com")

    expect(page).to be_axe_clean

    click_on "All"
    select_row("customer@example.com")
    click_on "Delete"
    expect(page).to have_content("Users were successfully removed.")
    expect(page).not_to have_content("customer@example.com")
    expect(Spree.user_class.count).to eq(3)
  end

  context "when a user has recently signed in" do
    let(:sign_in_date) { DateTime.now }

    before do
      allow_any_instance_of(Spree.user_class).to receive(:try).with(:email).and_call_original
      allow_any_instance_of(Spree.user_class).to receive(:try).with(:last_sign_in_at).and_return(sign_in_date)
    end

    it "lists the last time they were active" do
      visit "/admin/users"
      expect(page).to have_content("Last active")
      expect(page).to have_content("Less than a minute ago")
      expect(page).not_to have_content("Never")
    end
  end

  context "when editing an existing user" do
    before do
      # This is needed for the actions which are still powered by the backend
      # and not the new admin. (#update, etc.)
      stub_authorization!(admin)

      create(:user, email: "customer@example.com")
      visit "/admin/users"
      find_row("customer@example.com").click
    end

    it "shows the edit page" do
      expect(page).to have_content("Users / customer@example.com")
      expect(page).to have_content("Lifetime Stats")
      expect(page).to have_content("Roles")
      expect(find("label", text: /admin/i).find("input[type=checkbox]").checked?).to eq(false)
    end

    it "allows editing of the existing user" do
      # API key interactions
      expect(page).to have_content("No key")
      click_on "Generate API key"
      expect(page).to have_content("Key generated")
      expect(page).to have_content("(hidden)")

      click_on "Regenerate key"
      expect(page).to have_content("Key generated")
      expect(page).to have_content("(hidden)")

      click_on "Clear key"
      expect(page).to have_content("Key cleared")
      expect(page).to have_content("No key")

      # Update user
      within("form.edit_user") do
        fill_in "Email", with: "dogtown@example.com"
        find("label", text: /admin/i).find("input[type=checkbox]").check
        click_on "Update"
      end

      expect(page).to have_content("Users / dogtown@example.com")
      expect(find("label", text: /admin/i).find("input[type=checkbox]").checked?).to eq(true)

      # Cancel out of editing
      within("form.edit_user") do
        fill_in "Email", with: "newemail@example.com"
        click_on "Cancel"
      end

      expect(page).not_to have_content("newemail@example.com")
    end
  end
end
