# frozen_string_literal: true

require 'spec_helper'

describe "Taxonomies", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists taxonomies and allows deleting them" do
    create(:taxonomy, name: "Categories")
    create(:taxonomy, name: "Brand")

    visit "/admin/taxonomies"
    expect(page).to have_content("Categories")
    expect(page).to have_content("Brand")

    expect(page).to be_axe_clean

    select_row("Categories")
    click_on "Delete"
    expect(page).to have_content("Taxonomies were successfully removed.")
    expect(page).not_to have_content("Categories")
    expect(Spree::Taxonomy.count).to eq(1)
  end
end
