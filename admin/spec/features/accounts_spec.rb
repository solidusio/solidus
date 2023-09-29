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
end
