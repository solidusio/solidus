# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :feature do
  context "as admin user" do
    stub_authorization!

    context "visiting the homepage" do
      before(:each) do
        visit spree.admin_path
      end

      it "should have a link to overview" do
        within_nav { expect(page).to have_link(nil, href: "/admin") }
      end

      it "should have a link to orders" do
        expect(page).to have_link("Orders", href: "/admin/orders")
      end

      it "should have a link to products" do
        expect(page).to have_link("Products", href: "/admin/products", count: 2)
      end

      it "should have a link to configuration" do
        expect(page).to have_link("Settings", href: "/admin/stores")
      end
    end

    context "visiting the products tab" do
      before(:each) do
        visit spree.admin_products_path
      end

      it "should have a link to products" do
        within(".selected .admin-subnav") { expect(page).to have_link("Products", href: "/admin/products") }
      end

      it "should have a link to option types" do
        within(".selected .admin-subnav") { expect(page).to have_link("Option Types", href: "/admin/option_types") }
      end

      it "should have a link to property types" do
        within(".selected .admin-subnav") { expect(page).to have_link("Property Types", href: "/admin/properties") }
      end
    end
  end

  context "as fakedispatch user" do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(nil)
    end

    custom_authorization! do |_user|
      can [:admin, :home], :dashboards
      can [:admin, :edit, :index, :show], Spree::Order
      cannot [:admin], Spree::StockLocation
      can [:admin], Spree::Zone
    end

    it "should only display tabs fakedispatch has access to" do
      visit spree.admin_path
      expect(page).to have_link("Orders")
      expect(page).not_to have_link("Products")
      expect(page).not_to have_link("Promotions")
      expect(page).to have_link("Settings")
      expect(page).not_to have_link("Stock Locations", visible: false)
      expect(page).to have_link("Zones", visible: false)
    end
  end
end
