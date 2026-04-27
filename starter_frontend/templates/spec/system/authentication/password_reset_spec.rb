# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Reset Password', type: :system do
  let!(:store) { create(:store) }

  background do
    ActionMailer::Base.default_url_options[:host] = 'http://example.com'
  end

  context 'when an account with this email address exists' do
    let!(:user) { create(:user, email: 'foobar@example.com', password: 'secret', password_confirmation: 'secret') }

    scenario 'allows a user to supply an email for the password reset' do
      visit login_path
      click_link 'Forgot Password?'
      fill_in_email
      click_button 'Reset my password'
      expect(page).to have_text 'you will receive an email with instructions'
    end
  end

  # Test that we are extending the functionality from
  # https://github.com/solidusio/solidus_auth_devise/pull/155
  # to the non-admin login
  scenario 'does not reveal email addresses if they are not found' do
    visit login_path
    click_link 'Forgot Password?'
    fill_in_email
    click_button 'Reset my password'
    expect(page).to_not have_text "Email not found"
    expect(page).to have_text 'you will receive an email with instructions'
  end

  def fill_in_email
    fill_in 'Email', with: 'foobar@example.com'
  end
end
