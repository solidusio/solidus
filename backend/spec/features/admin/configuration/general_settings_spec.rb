require 'spec_helper'

describe "General Settings", type: :feature, js: true do
  stub_authorization!

  let!(:store) do
    create(:store, name: 'Test Store', url: 'test.example.org',
           mail_from_address: 'test@example.org')
  end

  before(:each) do
    visit spree.admin_path
    click_link "Settings"
    click_link "General Settings"
  end

  context "visiting general settings" do
    it "should have the right content" do
      expect(page).to have_content("General Settings")
      expect(page).to have_field("store_name", with: "Test Store")
      expect(page).to have_field("store_url", with: "test.example.org")
      expect(page).to have_field("store_mail_from_address", with: "test@example.org")
    end
  end

  context "editing general settings" do
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

  context "clearing the cache" do
    it "should clear the cache" do
      expect(page).to_not have_content(Spree.t(:clear_cache_ok))
      expect(page).to have_content(Spree.t(:clear_cache_warning))

      click_button "Clear Cache"

      expect(page).to have_content(Spree.t(:clear_cache_ok))
    end
  end
end
