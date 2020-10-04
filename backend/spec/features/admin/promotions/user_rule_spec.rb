# frozen_string_literal: true

require 'spec_helper'

feature 'Promotion with user rule', js: true do
  stub_authorization!

  given(:promotion) { create :promotion }

  background do
    visit spree.edit_admin_promotion_path(promotion)
  end

  context "multiple users" do
    let!(:user) { create(:user, email: 'foo@example.com') }
    let!(:other_user) { create(:user, email: 'bar@example.com') }

    scenario "searching a user" do
      select "User", from: "Discount Rules"
      within("#rules_container") { click_button "Add" }

      select2_search "foo", from: "Choose users", select: false

      expect(page).to have_content('foo@example.com')
      expect(page).not_to have_content('bar@example.com')
    end
  end

  context "with an attempted XSS" do
    let(:xss_string) { %(<script>throw("XSS")</script>) }
    given!(:user) { create(:user, email: xss_string) }

    scenario "adding an option value rule" do
      select "User", from: "Discount Rules"
      within("#rules_container") { click_button "Add" }

      select2_search "<script>", from: "Choose users"

      expect(page).to have_content(xss_string)
    end
  end
end
