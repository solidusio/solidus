# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Accounts', type: :system do
  include SolidusStarterFrontend::System::CheckoutHelpers

  before { setup_custom_products }

  context 'editing' do
    scenario 'can edit an admin user' do
      user = create(:admin_user, email: 'admin@person.com', password: 'password', password_confirmation: 'password')
      visit login_path

      fill_in 'Email', with: user.email
      fill_in 'Password:', with: user.password
      click_button 'Login'

      click_link '', href: '/account'
      expect(page).to have_text 'admin@person.com'
    end

    scenario 'can edit a new user' do
      stub_spree_preferences(Spree::Auth::Config, signout_after_password_change: false)
      visit signup_path

      fill_in 'Email', with: 'email@person.com'
      fill_in 'Password:', with: 'password'
      fill_in 'Password Confirmation', with: 'password'
      click_button 'Create'

      click_link '', href: '/account'
      expect(page).to have_text 'email@person.com'
      click_link 'Edit'

      fill_in 'Password:', with: 'foobar'
      fill_in 'Password Confirmation', with: 'foobar'
      click_button 'Update'

      expect(page).to have_text 'email@person.com'
      expect(page).to have_text 'Account updated'
    end

    scenario 'can edit an existing user account' do
      stub_spree_preferences(Spree::Auth::Config ,signout_after_password_change: false)
      user = create(:user, email: 'email@person.com', password: 'secret', password_confirmation: 'secret')
      visit login_path

      fill_in 'Email', with: user.email
      fill_in 'Password:', with: user.password
      click_button 'Login'

      click_link '', href: '/account'
      expect(page).to have_text 'email@person.com'
      click_link 'Edit'

      fill_in 'Password:', with: 'foobar'
      fill_in 'Password Confirmation', with: 'foobar'
      click_button 'Update'

      expect(page).to have_text 'email@person.com'
      expect(page).to have_text 'Account updated'
    end
  end
end
