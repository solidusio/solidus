# frozen_string_literal: true

require 'spec_helper'
require "solidus_admin/testing_support/shared_examples/moveable"

describe "Payment Methods", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists users and allows deleting them" do
    create(:check_payment_method, name: "Check", active: true)
    create(:simple_credit_card_payment_method, name: "Credit Card", active: false)
    create(:store_credit_payment_method, name: "Store Credit Users", available_to_users: true)
    create(:store_credit_payment_method, name: "Store Credit Admins", available_to_admin: true)

    visit "/admin/payment_methods"
    expect(page).to have_content("Check")
    expect(page).not_to have_content("Credit Card")
    expect(page).to have_content("Store Credit Users")
    expect(page).to have_content("Store Credit Admins")
    click_on "Inactive"
    expect(page).not_to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).not_to have_content("Store Credit Users")
    expect(page).not_to have_content("Store Credit Admins")
    click_on "Admin"
    expect(page).to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).to have_content("Store Credit Admins")
    expect(page).not_to have_content("Store Credit Users")
    click_on "Storefront"
    expect(page).to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).not_to have_content("Store Credit Admins")
    expect(page).to have_content("Store Credit Users")
    click_on "All"
    expect(page).to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).to have_content("Store Credit Admins")
    expect(page).to have_content("Store Credit Users")

    expect(page).to be_axe_clean

    select_row("Check")
    accept_confirm("Are you sure you want to delete 1 payment method?") { click_on "Delete" }
    expect(page).to have_content("Payment methods were successfully removed.")
    expect(page).not_to have_content("Check")
    expect(Spree::PaymentMethod.count).to eq(3)
  end

  it_behaves_like "features: sortable" do
    let(:factory) { :payment_method }
    let(:displayed_attribute) { :name }
    let(:path) { solidus_admin.payment_methods_path }
  end

  context "creating payment method" do
    before { create(:store, name: "Store") }
    context "with valid attributes" do
      it "creates payment method" do
        visit "/admin/payment_methods"
        click_on "Add new"

        expect(page).to have_current_path("/admin/payment_methods/new")
        expect(page).to be_axe_clean

        fill_in "Name", with: "Checking"
        fill_in "Description", with: "Payment Method Description"
        switch "Auto Capture"
        solidus_select "Check Payments", from: "Type"
        fill_in "Server", with: "test"
        switch "Test Mode"
        check "Active"
        solidus_select("Store", from: "Stores")
        check "Available to Admin"
        check "Available to Users"

        click_on "Save"

        expect(page).to have_content("Payment method was successfully created.")
        expect(page).to have_content("Checking")
        expect(page).to have_content("Check Payments")
      end
    end

    context "with invalid attributes" do
      it "shows validation errors" do
        visit "/admin/payment_methods"
        click_on "Add new"
        click_on "Save"
        expect(page).to have_content("can't be blank")
      end
    end
  end

  context "updating payment method" do
    before { create(:payment_method, name: "Check payments") }

    context "with valid attributes" do
      it "updates payment method" do
        visit "/admin/payment_methods"
        click_on "Check payments"

        fill_in "Name", with: "Checking payments"
        solidus_select "Check Payments", from: "Type"
        click_on "Save"

        expect(page).to have_content("Payment method was successfully updated.")
        expect(page).to have_content("Checking payments")
        expect(page).to have_content("Check Payments")
      end
    end

    context "with invalid attributes" do
      it "shows validation errors" do
        visit "/admin/payment_methods"
        click_on "Check payments"

        fill_in "Name", with: ""
        click_on "Save"

        expect(page).to have_content("can't be blank")
      end
    end
  end
end
