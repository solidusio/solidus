# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Checkout', :js, type: :system do
  include  SolidusStarterFrontend::System::CheckoutHelpers

  given!(:store) { create(:store) }
  given!(:country) { create(:country, name: 'United States', states_required: true) }
  given!(:state) { create(:state, name: 'Alabama', country: country) }
  given!(:shipping_method) do
    shipping_method = create(:shipping_method)
    calculator = Spree::Calculator::Shipping::PerItem.create!(calculable: shipping_method, preferred_amount: 10)
    shipping_method.calculator = calculator
    shipping_method.tap(&:save)
  end

  given!(:zone)    { create(:zone) }
  given!(:address) { create(:address) }
  given!(:payment_method){ create :check_payment_method }

  background do
    @product = create(:product, name: 'Solidus hoodie')
    @product.master.stock_items.first.set_count_on_hand(1)

    # Bypass gateway error on checkout | ..or stub a gateway
    stub_spree_preferences(allow_checkout_on_gateway_error: true)

    visit products_path
  end

  # Regression test for https://github.com/solidusio/solidus/issues/1588
  scenario 'leaving and returning to address step' do
    stub_spree_preferences(Spree::Auth::Config, registration_step: true)
    click_link 'Solidus hoodie'
    click_button 'Add To Cart'
    within('h1') { expect(page).to have_text 'Shopping Cart' }
    click_button 'Checkout'

    within '#guest_checkout' do
      fill_in 'Email', with: 'test@example.com'
    end
    click_on 'Continue'

    click_on 'Cart'

    click_on 'Checkout'

    expect(page).to have_content "Billing Address"
  end

  context 'without payment being required' do
    scenario 'allow a visitor to checkout as guest, without registration' do
      click_link 'Solidus hoodie'
      click_button 'Add To Cart'
      within('h1') { expect(page).to have_text 'Shopping Cart' }
      click_button 'Checkout'

      expect(page).to have_content(/Checkout as a Guest/i)

      within('#guest_checkout') { fill_in 'Email', with: 'spree@test.com' }
      click_button 'Continue'

      expect(page).to have_text(/Billing Address/i)
      expect(page).to have_text(/Shipping Address/i)

      fill_addresses_fields_with(address)
      click_button 'Save and Continue'

      expect(page).to have_content "package from NY Warehouse"
      click_button 'Save and Continue'

      expect(page).to have_content "Check"
      click_button 'Save and Continue'

      expect(page).to have_content "Put your terms and conditions here"
      check 'Agree to Terms of Service'
      click_button 'Place Order'

      expect(page).to have_text 'Your order has been processed successfully'
    end

    scenario 'associate an uncompleted guest order with user after logging in' do
      user = create(:user, email: 'email@person.com', password: 'password', password_confirmation: 'password')
      click_link 'Solidus hoodie'
      click_button 'Add To Cart'

      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password:', with: user.password
      click_button 'Login'
      expect(page).to have_text 'Logged in successfully'
      click_link 'Cart'

      expect(page).to have_text 'Solidus hoodie'
      within('h1') { expect(page).to have_text 'Shopping Cart' }

      click_button 'Checkout'
      expect(page).to have_text(/Billing Address/i, wait: 10)

      fill_addresses_fields_with(address)
      click_button 'Save and Continue'

      expect(page).to have_content "package from NY Warehouse"
      click_button 'Save and Continue'

      expect(page).to have_content "Check"
      click_button 'Save and Continue'

      expect(page).to have_content "Put your terms and conditions here"
      check 'Agree to Terms of Service'
      click_button 'Place Order'

      expect(page).to have_text 'Your order has been processed successfully'
      expect(Spree::Order.first.user).to eq user
    end

    # Regression test for #890
    scenario 'associate an incomplete guest order with user after successful password reset' do
      create(:user, email: 'email@person.com', password: 'password', password_confirmation: 'password')
      click_link 'Solidus hoodie'
      click_button 'Add To Cart'

      visit login_path
      click_link 'Forgot Password?'
      fill_in 'spree_user_email', with: 'email@person.com'
      click_button 'Reset my password'

      # Need to do this now because the token stored in the DB is the encrypted version
      # The 'plain-text' version is sent in the email and there's one way to get that!
      reset_password_email = ActionMailer::Base.deliveries.first
      token_url_regex = /\/user\/password\/edit\?reset_password_token=(.*)$/
      token = token_url_regex.match(reset_password_email.body.to_s)[1]

      visit edit_spree_user_password_path(reset_password_token: token)
      fill_in 'Password:', with: 'password'
      fill_in 'Password Confirmation', with: 'password'
      click_button 'Update'

      click_link 'Cart'
      click_button 'Checkout'

      fill_addresses_fields_with(address)
      click_button 'Save and Continue'

      expect(page).not_to have_text 'Email is invalid'
    end

    scenario 'allow a user to register during checkout' do
      click_link 'Solidus hoodie'
      click_button 'Add To Cart'
      click_button 'Checkout'

      within '#existing-customer' do
        click_link 'Create a new account'
      end

      fill_in 'Email', with: 'email@person.com'
      fill_in 'Password:', with: 'spree123'
      fill_in 'Password Confirmation', with: 'spree123'
      click_button 'Create'

      expect(page).to have_text 'You have signed up successfully.'

      fill_addresses_fields_with(address)
      click_button 'Save and Continue'

      expect(page).to have_content "package from NY Warehouse"
      click_button 'Save and Continue'

      expect(page).to have_content "Check"
      click_button 'Save and Continue'

      expect(page).to have_content "Put your terms and conditions here"
      check 'Agree to Terms of Service'
      click_button 'Place Order'

      expect(page).to have_text 'Your order has been processed successfully'
      expect(Spree::Order.first.user).to eq Spree::User.find_by(email: 'email@person.com')
    end
  end
end
