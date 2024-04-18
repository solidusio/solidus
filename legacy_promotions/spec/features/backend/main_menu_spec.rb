# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Main Menu", type: :feature do
  context 'as admin user' do
    stub_authorization!

    context "visiting the homepage" do
      before(:each) do
        visit spree.admin_path
      end

      it "should have a link to promotions" do
        expect(page).to have_link("Promotions", href: "/admin/promotions", count: 2)
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
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(nil)
    end

    custom_authorization! do |_user|
      can [:admin, :home], :dashboards
      can [:admin, :edit, :index, :show], Spree::Order
      cannot [:admin], Spree::StockLocation
      can [:admin], Spree::Zone
    end

    it 'should only display tabs fakedispatch has access to' do
      visit spree.admin_path
      expect(page).to have_link('Orders')
      expect(page).not_to have_link('Products')
      expect(page).not_to have_link('Promotions')
      expect(page).to have_link('Settings')
      expect(page).not_to have_link('Stock Locations', visible: false)
      expect(page).to have_link('Zones', visible: false)
    end
  end
end
