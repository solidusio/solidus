# frozen_string_literal: true

require 'spec_helper'

describe "Accounts", type: :feature do
  let(:user) { create(:admin_user, email: 'admin@example.com') }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
  end

  it "shows account info" do
    without_partial_double_verification do
      allow(Spree::Core::Engine.routes.url_helpers).to receive(:admin_logout_path).and_return('/admin/logout')
    end

    visit "/admin/account"

    expect(page).to have_content("Logged in as #{user.email}")
    expect(page).to have_content("Log out")
  end
end
