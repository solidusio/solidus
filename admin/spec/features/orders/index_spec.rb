# frozen_string_literal: true

require 'spec_helper'

describe "Orders", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists orders", :js do
    create(:order, number: "R123456789", total: 19.99)

    visit "/admin/orders"
    click_on "In Progress"

    expect(page).to have_content("admin@example.com")
    expect(page).to have_content("R123456789")
    expect(page).to have_content("$19.99")
    expect(page).to be_axe_clean
  end

  context 'with different currency' do
    around do |example|
      currency_was = Spree::Config.currency
      Spree::Config.currency = 'EUR'
      example.run
      Spree::Config.currency = currency_was
    end

    it 'displays correct currency' do
      create(:order, total: 19.99)
      visit "/admin/orders"
      click_on "In Progress"

      expect(page).to have_content("€19.99")
    end
  end

  context "with multiple stores", :js do
    let!(:order_in_default_store) { create :order }
    let(:another_store) { create :store, name: "Another Store" }
    let!(:order_in_another_store) { create :order, store: another_store }

    it "can filter orders by store" do
      visit solidus_admin.orders_path

      click_on "In Progress"

      expect(page).to have_content(order_in_default_store.number)
      expect(page).to have_content(order_in_another_store.number)

      click_on "Filter"

      within("div[role='search']") do
        find('details', text: "Store").click
        expect(page).to have_content("Another Store")

        find('label', text: "Another Store").click
      end

      expect(page).to have_content(order_in_another_store.number)
      expect(page).to_not have_content(order_in_default_store.number)
    end
  end
end
