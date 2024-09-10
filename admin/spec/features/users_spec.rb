# frozen_string_literal: true

require "spec_helper"

describe "Users", :js, type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

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
end
