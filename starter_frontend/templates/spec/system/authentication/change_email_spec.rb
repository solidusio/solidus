# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Change email', type: :system do
  include SolidusStarterFrontend::System::CheckoutHelpers

  before { setup_custom_products }

  background do
    stub_spree_preferences(Spree::Auth::Config, signout_after_password_change: false)

    user = create(:user)
    visit root_path
    click_link '', href: '/login'

    fill_in 'spree_user[email]', with: user.email
    fill_in 'spree_user[password]', with: 'secret'
    click_button 'Login'

    visit edit_account_path
  end

  scenario 'work with correct password' do
    fill_in 'user[email]', with: 'tests@example.com'
    fill_in 'user[password]', with: 'password'
    fill_in 'user[password_confirmation]', with: 'password'
    click_button 'Update'

    expect(page).to have_text 'Account updated'
    expect(page).to have_text 'tests@example.com'
  end
end
