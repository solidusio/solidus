# frozen_string_literal: true

require 'spec_helper'

describe "Orders", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists orders", :js do
    create(:order, number: "R123456789", total: 19.99)

    visit "/admin/orders"
    click_on "In Progress"

    expect(page).to have_content("admin@example.com")
  end
end
