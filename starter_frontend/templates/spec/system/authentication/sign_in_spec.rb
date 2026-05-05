# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Sign In', type: :system do
  include_context "featured products"

  background do
    @user = create(:user, email: 'email@person.com', password: 'secret', password_confirmation: 'secret')
    visit login_path
  end

  scenario 'let a user sign in successfully' do
    fill_in 'Email', with: @user.email
    fill_in 'Password:', with: @user.password
    click_button 'Login'

    expect(page).to have_text 'Logged in successfully'
    expect(page).not_to have_link nil, href: '/login'
    expect(page).to have_link nil, href: '/account'
    expect(current_path).to eq '/'
  end

  scenario 'show validation errors' do
    fill_in 'Email', with: @user.email
    fill_in 'Password:', with: 'wrong_password'
    click_button 'Login'

    expect(page).to have_text 'Invalid email or password'
    expect(page).to have_text 'Login'
  end

  it "should store the user previous location" do
    visit account_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Login"
    expect(current_path).to eq "/account"
  end
end
