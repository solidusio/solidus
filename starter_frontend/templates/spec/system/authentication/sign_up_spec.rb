# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Sign Up', type: :system do
  include_context "featured products"

  context 'with valid data' do
    scenario 'create a new user' do
      visit signup_path

      fill_in 'Email', with: 'email@person.com'
      fill_in 'Password:', with: 'password'
      fill_in 'Password Confirmation', with: 'password'
      click_button 'Create'

      expect(page).to have_text 'You have signed up successfully.'
      expect(Spree::User.count).to eq(1)
    end
  end

  context 'with invalid data' do
    scenario 'does not create a new user' do
      visit signup_path

      fill_in 'Email', with: 'email@person.com'
      fill_in 'Password:', with: 'password'
      fill_in 'Password Confirmation', with: ''
      click_button 'Create'

      expect(page).to have_css '#errorExplanation'
      expect(Spree::User.count).to eq(0)
    end
  end
end
