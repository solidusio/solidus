# frozen_string_literal: true

require 'spec_helper'

describe "Homepage", type: :feature do
  context 'as admin user' do
    stub_authorization!

    context "visiting the homepage" do
      before(:each) do
        visit spree.admin_path
      end

      it "should have a link to overview" do
        within(".admin-nav-header") { expect(page).to have_link(nil, href: "/admin") }
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

      it "should have a link to promotions" do
        expect(page).to have_link("Promotions", href: "/admin/promotions", count: 2)
      end
    end

    context "visiting the products tab" do
      before(:each) do
        visit spree.admin_products_path
      end

      it "should have a link to products" do
        within('.selected .admin-subnav') { expect(page).to have_link("Products", href: "/admin/products") }
      end

      it "should have a link to option types" do
        within('.selected .admin-subnav') { expect(page).to have_link("Option Types", href: "/admin/option_types") }
      end

      it "should have a link to property types" do
        within('.selected .admin-subnav') { expect(page).to have_link("Property Types", href: "/admin/properties") }
      end
    end

    context "visiting the promotions tab" do
      before(:each) do
        visit spree.admin_promotions_path
      end

      it "should have a link to promotions" do
        within('.selected .admin-subnav') { expect(page).to have_link("Promotions", href: "/admin/promotions") }
      end

      it "should have a link to promotion categories" do
        within('.selected .admin-subnav') { expect(page).to have_link("Promotion Categories", href: "/admin/promotion_categories") }
      end
    end
  end

  context 'as fakedispatch user' do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:try_spree_current_user).and_return(nil)
    end

    custom_authorization! do |_user|
      can [:admin, :home], :dashboards
      can [:admin, :edit, :index, :read], Spree::Order
    end

    it 'should only display tabs fakedispatch has access to' do
      visit spree.admin_path
      expect(page).to have_link('Orders')
      expect(page).not_to have_link('Products')
      expect(page).not_to have_link('Promotions')
      expect(page).not_to have_link('Settings')
    end
  end
end
