# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"

describe "Payment Methods", :js, type: :feature do
  let(:preferences_with_preference_sources) {
    Spree::Preferences::StaticModelPreferences.new.tap { |preferences|
      preferences.add Spree::PaymentMethod::BogusCreditCard,
        "static_preferences",
        {
          bogus_array: ["static"],
          bogus_boolean: false,
          bogus_decimal: 22.123,
          bogus_encrypted_string: "static-encrypted-string-value",
          bogus_hash: {static: true},
          bogus_integer: 999,
          bogus_password: "incredibly-strong-static-one",
          bogus_string: "static-string-value",
          bogus_text: "Statically set text value."
        }
    }
  }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?).and_return(true)
    sign_in create(:admin_user, email: "admin@example.com")

    stub_spree_preferences(static_model_preferences: preferences_with_preference_sources)
  end

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
    accept_turbo_confirm("Are you sure you want to delete 1 payment method?") { click_on "Delete" }
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
    before do
      create :store, default: true, name: "Default Store"
      create :store, name: "Store"
    end

    context "with valid attributes" do
      it "creates payment method" do
        visit "/admin/payment_methods"
        click_on "Add new"

        expect(solidus_select_control("Stores")).to have_content "Default Store"

        expect(page).to have_current_path("/admin/payment_methods/new")
        expect(page).to be_axe_clean

        fill_in "Name", with: "Checking"
        fill_in "Description", with: "Payment Method Description"
        solidus_select "No", from: "Auto Capture"

        within(panel(title: "Deployment")) do
          expect(field?("Test Mode")).to eq true
          expect(field?("Server")).to eq true
          expect(field?("Bogus Boolean Preference")).to eq true
          expect(field?("Bogus Decimal Preference")).to eq true
          expect(field?("Bogus Encrypted String Preference")).to eq true
          expect(field?("Bogus Integer Preference")).to eq true
          expect(field?("Bogus Password Preference")).to eq true
          expect(field?("Bogus String Preference")).to eq true
          expect(field?("Bogus Text Preference")).to eq true

          solidus_select "Check Payments", from: "Type"

          expect(field?("Test Mode")).to eq true
          expect(field?("Server")).to eq true
          expect(field?("Bogus Boolean Preference")).to eq false
          expect(field?("Bogus Decimal Preference")).to eq false
          expect(field?("Bogus Encrypted String Preference")).to eq false
          expect(field?("Bogus Integer Preference")).to eq false
          expect(field?("Bogus Password Preference")).to eq false
          expect(field?("Bogus String Preference")).to eq false
          expect(field?("Bogus Text Preference")).to eq false
        end

        fill_in "Server", with: "australia-test-1"
        switch "Test Mode", on: false
        check "Active"

        solidus_select("Store", from: "Stores")
        check "Available to Admin"
        check "Available to Users"

        click_on "Save"

        expect(page).to have_content("Payment method was successfully created.")
        expect(page).to have_content("Checking")
        expect(page).to have_content("Check Payments")
        click_on("Check Payments")

        expect(field_value("Test Mode")).to eq false
        expect(field_value("Server")).to eq "australia-test-1"
      end
    end

    context "with a preference source" do
      it "creates payment method" do
        visit "/admin/payment_methods"
        click_on "Add new"

        expect(solidus_select_control("Stores")).to have_content "Default Store"

        expect(page).to have_current_path("/admin/payment_methods/new")

        fill_in "Name", with: "Bogus Credit Card"
        fill_in "Description", with: "Payment Method Description"
        solidus_select "No", from: "Auto Capture"
        solidus_select "Bogus Credit Card", from: "Type"

        disabled_inputs = find_all("[disabled]")
        expect(disabled_inputs.size).to be_zero

        solidus_select "static_preferences", from: "Preference Source"

        disabled_inputs = find_all("[disabled]")
        expect(disabled_inputs.size).not_to be_zero

        click_on "Save"

        expect(page).to have_content("Payment method was successfully created.")
        expect(page).to have_content("Bogus Credit Card")
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
    before { create(:payment_method, name: "Bogus Credit Card") }

    context "with valid attributes" do
      it "updates the payment method attributes" do
        visit "/admin/payment_methods"
        click_on "Bogus Credit Card"

        expect(page).to have_content "Edit Bogus Credit Card"

        switch "Bogus Boolean Preference"
        fill_in "Bogus Decimal Preference", with: "2.2"
        fill_in "Bogus Encrypted String Preference", with: "secret-value"
        fill_in "Bogus Integer Preference", with: "999"
        fill_in "Bogus Password Preference", with: "another-secret-value"
        fill_in "Bogus String Preference", with: "string-setting"

        click_on "Save"

        expect(page).to have_content("Payment method was successfully updated.")

        click_on "Bogus Credit Card"

        expect(field_value("Bogus Boolean Preference")).to eq true
        expect(field_value("Bogus Decimal Preference")).to eq "2.2"
        expect(field_value("Bogus Encrypted String Preference")).not_to be_blank
        expect(field_value("Bogus Integer Preference")).to eq "999"
        expect(field_value("Bogus Password Preference")).not_to be_blank
        expect(field_value("Bogus String Preference")).to eq "string-setting"
      end

      it "updates the payment method type" do
        visit "/admin/payment_methods"
        click_on "Bogus Credit Card"

        expect(page).to have_content "Edit Bogus Credit Card"

        fill_in "Name", with: "Checking payments"

        within(panel(title: "Deployment")) do
          expect(field?("Test Mode")).to eq true
          expect(field?("Server")).to eq true
          expect(field?("Bogus Boolean Preference")).to eq true
          expect(field?("Bogus Decimal Preference")).to eq true
          expect(field?("Bogus Encrypted String Preference")).to eq true
          expect(field?("Bogus Integer Preference")).to eq true
          expect(field?("Bogus Password Preference")).to eq true
          expect(field?("Bogus String Preference")).to eq true
          expect(field?("Bogus Text Preference")).to eq true

          solidus_select "Check Payments", from: "Type"

          expect(field?("Test Mode")).to eq true
          expect(field?("Server")).to eq true
          expect(field?("Bogus Boolean Preference")).to eq false
          expect(field?("Bogus Decimal Preference")).to eq false
          expect(field?("Bogus Encrypted String Preference")).to eq false
          expect(field?("Bogus Integer Preference")).to eq false
          expect(field?("Bogus Password Preference")).to eq false
          expect(field?("Bogus String Preference")).to eq false
          expect(field?("Bogus Text Preference")).to eq false
        end

        click_on "Save"

        expect(page).to have_content("Payment method was successfully updated.")
        expect(page).to have_content("Checking payments")
        expect(page).to have_content("Check Payments")
      end
    end

    context "with invalid attributes" do
      it "shows validation errors" do
        visit "/admin/payment_methods"
        click_on "Bogus Credit Card"

        fill_in "Name", with: ""
        click_on "Save"

        expect(page).to have_content("can't be blank")
      end
    end
  end

  def field_value(label)
    input = find(:label, text: label).find("input")

    case input["type"]&.to_sym
    when :checkbox then input.checked?
    else input.value
    end
  end

  # Use sparingly. This is a slow method due to finder wait times.
  def field?(label_text)
    find(:label, text: label_text)
    true
  rescue Capybara::ElementNotFound
    false
  end
end
