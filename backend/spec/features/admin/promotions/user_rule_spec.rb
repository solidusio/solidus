require 'spec_helper'

feature 'Promotion with user rule', js: true do
  stub_authorization!

  given(:promotion) { create :promotion }

  background do
    visit spree.edit_admin_promotion_path(promotion)
  end

  context "with an attempted XSS" do
    let(:xss_string) { %(<script>throw("XSS")</script>) }
    given!(:user) { create(:user, email: xss_string) }

    scenario "adding an option value rule" do
      select2 "User", from: "Add rule of type"
      within("#rules_container") { click_button "Add" }

      select2_search "<script>", from: "Choose users"

      expect(page).to have_content(xss_string)
    end
  end
end
