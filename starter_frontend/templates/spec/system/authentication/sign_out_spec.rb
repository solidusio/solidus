# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Sign Out', type: :system, js: true do
  include_context "featured products"
  
  given!(:user) do
   create(:user,
          email: 'email@person.com',
          password: 'secret',
          password_confirmation: 'secret')
  end

  background do
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password:', with: user.password
    # Regression test for #1257
    check 'Remember me'
    click_button 'Login'
  end

  scenario 'allow a signed in user to logout' do
    click_link '', href: '/account'
    click_button 'Logout'
    visit root_path
    expect(page).to have_link nil, href: '/login'
    expect(page).not_to have_button 'Logout'
  end
end
