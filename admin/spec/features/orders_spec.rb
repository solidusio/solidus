# frozen_string_literal: true

require 'spec_helper'

describe "Orders", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists products", :js do
    create(:order, number: "R123456789", total: 19.99)

    visit "/admin/orders"

    expect(page).to have_content("R123456789")
    expect(page).to have_content("$19.99")
    expect(page).to be_axe_clean
  end
end
