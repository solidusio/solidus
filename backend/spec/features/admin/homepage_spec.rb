require 'spec_helper'

describe "Homepage", type: :feature do
  context 'as admin user' do
    stub_authorization!

    context "visiting the homepage" do
      before(:each) do
        visit spree.admin_path
      end

      it "should have a link to overview" do
        within(".admin-nav-header") { page.find(:xpath, "a[@href='/admin']") }
      end

      it "should have a link to orders" do
        page.find_link("Orders")['/admin/orders']
      end

      it "should have a link to products" do
        page.assert_selector(:link, text: "Products", count: 2)
      end

      it "should have a link to reports" do
        page.find_link("Reports")['/admin/reports']
      end

      it "should have a link to configuration" do
        page.find_link("Settings")['/admin/configurations']
      end
    end

    context "visiting the products tab" do
      before(:each) do
        visit spree.admin_products_path
      end

      it "should have a link to products" do
        within('.selected .admin-subnav') { page.find_link("Products")['/admin/products'] }
      end

      it "should have a link to option types" do
        within('.selected .admin-subnav') { page.find_link("Option Types")['/admin/option_types'] }
      end

      it "should have a link to property types" do
        within('.selected .admin-subnav') { page.find_link("Property Types")['/admin/properties'] }
      end

      it "should have a link to prototypes" do
        within('.selected .admin-subnav') { page.find_link("Prototypes")['/admin/prototypes'] }
      end
    end
  end

  context 'as fakedispatch user' do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(nil)
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
      expect(page).not_to have_link('Reports')
      expect(page).not_to have_link('Settings')
    end
  end
end
