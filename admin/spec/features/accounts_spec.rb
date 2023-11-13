# frozen_string_literal: true

require 'spec_helper'

describe "Accounts", type: :feature do
  it "shows account info" do
    user = create(:admin_user, email: 'admin@example.com')
    stub_authorization! user
    sign_in user

    visit "/admin/account"

    expect(page).to have_content(user.email)
    expect(current_path).to eq("/admin/users/#{user.id}/edit")
  end

  it "can change locale", :js do
    I18n.config.available_locales_set << :"en-UK"
    I18n.config.available_locales_set << "en-UK"
    I18n.backend.store_translations('en-UK', spree: { i18n: { this_file_language: "English (UK)" } })

    user = create(:admin_user, email: 'admin@example.com')
    stub_authorization! user
    sign_in user

    visit "/admin/products"
    find('summary', text: user.email).click
    expect(page).to have_content("English (US)")
    select "English (UK)", from: "switch_to_locale"
    expect(page).to have_content("English (UK)")
    select "English (US)", from: 'switch_to_locale'
    expect(page).to have_content("English (US)")
  end
end
