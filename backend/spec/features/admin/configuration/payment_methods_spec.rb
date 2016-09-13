require 'spec_helper'

describe "Payment Methods", type: :feature do
  stub_authorization!

  before(:each) do
    visit spree.admin_path
    click_link "Settings"
    click_link "Payments"
  end

  context "admin visiting payment methods listing page" do
    it "should display existing payment methods" do
      create(:check_payment_method)
      click_link "Payment Methods"

      within("table#listing_payment_methods") do
        expect(all("th")[1].text).to eq("Name")
        expect(all("th")[2].text).to eq("Provider")
        expect(all("th")[3].text).to eq("Display")
        expect(all("th")[4].text).to eq("Active")
      end

      within('table#listing_payment_methods') do
        expect(page).to have_content("Spree::PaymentMethod::Check")
      end
    end
  end

  context "admin creating a new payment method" do
    it "should be able to create a new payment method" do
      click_link "Payment Methods"
      click_link "admin_new_payment_methods_link"
      expect(page).to have_content("New Payment Method")
      fill_in "payment_method_name", with: "check90"
      fill_in "payment_method_description", with: "check90 desc"
      select "PaymentMethod::Check", from: "gtwy-type"
      click_button "Create"
      expect(page).to have_content("successfully created!")
    end
  end

  context "admin editing a payment method" do
    before(:each) do
      create(:check_payment_method)
      click_link "Payment Methods"
      within("table#listing_payment_methods") do
        click_icon(:edit)
      end
    end

    it "should be able to edit an existing payment method" do
      fill_in "payment_method_check_name", with: "Payment 99"
      click_button "Update"
      expect(page).to have_content("successfully updated!")
      expect(page).to have_field("payment_method_check_name", with: "Payment 99")
    end

    it "should display validation errors" do
      fill_in "payment_method_check_name", with: ""
      click_button "Update"
      expect(page).to have_content("Name can't be blank")
    end
  end

  context "changing type and payment_source", js: true do
    after do
      # cleanup
      Spree::Config.static_model_preferences.for_class(Spree::Gateway::Bogus).clear
    end

    it "displays message when changing type" do
      create(:credit_card_payment_method)
      click_link "Payment Methods"
      click_icon :edit
      expect(page).to have_content('Test Mode')

      select2_search 'Spree::PaymentMethod::Check', from: 'Provider'
      expect(page).to have_content('you must save first')
      expect(page).to have_no_content('Test Mode')

      # change back
      select2_search 'Spree::Gateway::Bogus', from: 'Provider'
      expect(page).to have_no_content('you must save first')
      expect(page).to have_content('Test Mode')
    end

    it "displays message when changing preference source" do
      Spree::Config.static_model_preferences.add(Spree::Gateway::Bogus, 'my_prefs', {})

      create(:credit_card_payment_method)
      click_link "Payment Methods"
      click_icon :edit
      expect(page).to have_content('Test Mode')

      select2_search 'my_prefs', from: 'Preference Source'
      expect(page).to have_content('you must save first')
      expect(page).to have_no_content('Test Mode')

      # change back
      select2_search 'Custom', from: 'Preference Source'
      expect(page).to have_no_content('you must save first')
      expect(page).to have_content('Test Mode')
    end

    it "updates successfully and keeps secrets" do
      Spree::Config.static_model_preferences.add(Spree::Gateway::Bogus, 'my_prefs', { server: 'secret' })

      create(:credit_card_payment_method)
      click_link "Payment Methods"
      click_icon :edit

      select2_search 'my_prefs', from: 'Preference Source'
      click_on 'Update'
      expect(page).to have_content('Using static preferences')
      expect(page).to have_no_content('secret')

      # change back
      select2_search 'Custom', from: 'Preference Source'
      click_on 'Update'
      expect(page).to have_content('Test Mode')
      expect(page).to have_no_content('secret')
    end
  end
end
