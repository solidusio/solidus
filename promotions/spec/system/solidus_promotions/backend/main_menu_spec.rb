# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Main Menu", type: :feature do
  context "as admin user" do
    stub_authorization!

    context "visiting the homepage" do
      before(:each) do
        visit spree.admin_path
      end

      it "should have a link to promotions" do
        expect(page).to have_link("Promotions (new)", href: solidus_promotions.admin_promotions_path, count: 2)
      end
      it "should have a link to legacy promotions" do
        expect(page).to have_link("Promotions", href: spree.admin_promotions_path, count: 2)
      end
    end

    context "visiting the promotions tab" do
      before(:each) do
        visit solidus_promotions.admin_promotions_path
      end

      it "should have a link to promotions" do
        within(".selected .admin-subnav") { expect(page).to have_link("Promotions (new)", href: solidus_promotions.admin_promotions_path) }
      end

      it "should have a link to promotion categories" do
        within(".selected .admin-subnav") { expect(page).to have_link("Promotion Categories (new)", href: solidus_promotions.admin_promotion_categories_path) }
      end
    end

    context "visiting the legacy promotions tab" do
      before(:each) do
        visit spree.admin_promotions_path
      end

      it "should have a link to promotions" do
        within(".selected .admin-subnav") { expect(page).to have_link("Promotions", href: spree.admin_promotions_path) }
      end

      it "should have a link to promotion categories" do
        within(".selected .admin-subnav") { expect(page).to have_link("Promotion Categories", href: spree.admin_promotion_categories_path) }
      end
    end
  end
end
