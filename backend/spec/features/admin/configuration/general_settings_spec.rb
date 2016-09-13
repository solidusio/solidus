require 'spec_helper'

describe "Store", type: :feature, js: true do
  stub_authorization!

  let!(:store) do
    create(:store, name: 'Test Store', url: 'test.example.org',
           mail_from_address: 'test@example.org')
  end

  before(:each) do
    visit spree.admin_path
    click_link "Settings"
    within('.admin-nav') do
      click_link "Store"
    end
  end

  context "visiting general store settings" do
    it "should have the right content" do
      expect(page).to have_content("SettingsStore")
      expect(page).to have_field("store_name", with: "Test Store")
      expect(page).to have_field("store_url", with: "test.example.org")
      expect(page).to have_field("store_mail_from_address", with: "test@example.org")
    end
  end

  context "editing general store settings" do
    it "should be able to update the site name" do
      fill_in "store_name", with: "Spree Demo Site99"
      fill_in "store_mail_from_address", with: "spree@example.org"
      click_button "Update"

      assert_successful_update_message(:general_settings)
      expect(page).to have_field("store_name", with: "Spree Demo Site99")
      expect(page).to have_field("store_mail_from_address", with: "spree@example.org")
    end
  end

  context "update fails" do
    it "should display the error" do
      fill_in "Site Name", with: ""
      click_button "Update"

      expect(page).to have_content("can't be blank")
      expect(page).to have_field("Site Name", with: "")
    end
  end
end
