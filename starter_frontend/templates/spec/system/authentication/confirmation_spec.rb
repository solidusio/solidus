# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.feature 'Confirmation', type: :system do
  include_context "featured products"

  before do
    allow(Spree::UserMailer).to receive(:confirmation_instructions)
      .and_return(double(deliver: true))
  end

  let!(:store) { create(:store) }

  background do
    ActionMailer::Base.default_url_options[:host] = 'http://example.com'
  end

  scenario 'create a new user', js: true, confirmable: false do
    visit signup_path

    fill_in 'Email', with: 'email@person.com'
    fill_in 'Password:', with: 'password'
    fill_in 'Password Confirmation', with: 'password'
    click_button 'Create'

    expect(page).to have_text 'You have signed up successfully.'
    expect(Spree::User.last.confirmed?).to be(false)
  end
end
