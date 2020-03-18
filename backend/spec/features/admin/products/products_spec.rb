# frozen_string_literal: true

require 'spec_helper'

describe "Products", type: :feature do
  context "as admin user" do
    stub_authorization!

    before(:each) do
      visit spree.admin_path
    end

    def build_option_type_with_values(name, values)
      ot = FactoryBot.create(:option_type, name: name)
      values.each do |val|
        ot.option_values.create(name: val.downcase, presentation: val)
      end
      ot
    end

    context "listing products" do
      context "sorting" do
        before do
          create(:product, name: 'apache baseball cap', price: 10)
          create(:product, name: 'zomg shirt', price: 5)
        end

        it "should list existing products with correct sorting by name" do
          click_nav "Products"
          # Name ASC
          within_row(1) { expect(page).to have_content('apache baseball cap') }
          within_row(2) { expect(page).to have_content("zomg shirt") }

          # Name DESC
          click_link "admin_products_listing_name_title"
          within_row(1) { expect(page).to have_content("zomg shirt") }
          within_row(2) { expect(page).to have_content('apache baseball cap') }
        end

        it "should list existing products with correct sorting by price" do
          click_nav "Products"

          # Name ASC (default)
          within_row(1) { expect(page).to have_content('apache baseball cap') }
          within_row(2) { expect(page).to have_content("zomg shirt") }

          # Price DESC
          click_link "admin_products_listing_price_title"
          within_row(1) { expect(page).to have_content("zomg shirt") }
          within_row(2) { expect(page).to have_content('apache baseball cap') }
        end
      end

      context "currency displaying" do
        context "using Russian Rubles" do
          before do
            stub_spree_preferences(currency: "RUB")
          end

          let!(:product) do
            create(:product, name: "Just a product", price: 19.99)
          end

          # Regression test for https://github.com/spree/spree/issues/2737
          context "uses руб as the currency symbol" do
            it "on the products listing page" do
              visit spree.admin_products_path
              within_row(1) { expect(page).to have_content("19.99 ₽") }
            end
          end
        end
      end
      context "when none of the product prices are in the same currency as the default in the store" do
        before do
          stub_spree_preferences(currency: "MXN")
        end

        let!(:product) do
          create(:product, name: "Just a product", price: 19.99)
        end

        it 'defaults it to Spree::Config.currency and sets the price as blank' do
          stub_spree_preferences(currency: "USD")
          visit spree.admin_product_path(product)
          within("#product_price_field") do
            expect(page).to have_content("USD")
          end
        end
      end
    end

    context "searching products" do
      it "should be able to search deleted products", js: true do
        create(:product, name: 'apache baseball cap', deleted_at: "2011-01-06 18:21:13")
        create(:product, name: 'zomg shirt')

        click_nav "Products"
        expect(page).to have_content("zomg shirt")
        expect(page).not_to have_content("apache baseball cap")
        check "Show Deleted"
        click_button 'Search'
        expect(find('input[name="q[with_discarded]"]')).to be_checked
        expect(page).to have_content("zomg shirt")
        expect(page).to have_content("apache baseball cap")
        uncheck "Show Deleted"
        click_button 'Search'
        expect(page).to have_content("zomg shirt")
        expect(page).not_to have_content("apache baseball cap")
      end

      it "should be able to search products by their properties" do
        create(:product, name: 'apache baseball cap', sku: "A100")
        create(:product, name: 'apache baseball cap2', sku: "B100")
        create(:product, name: 'zomg shirt')

        click_nav "Products"
        fill_in "Name", with: "ap"
        click_button 'Search'
        expect(page).to have_content("apache baseball cap")
        expect(page).to have_content("apache baseball cap2")
        expect(page).not_to have_content("zomg shirt")

        fill_in "SKU", with: "A1"
        click_button "Search"
        expect(page).to have_content("apache baseball cap")
        expect(page).not_to have_content("apache baseball cap2")
        expect(page).not_to have_content("zomg shirt")
      end

      # Regression test for https://github.com/solidusio/solidus/issues/2016
      it "should be able to search and sort by price" do
        product = create(:product, name: 'apache baseball cap', sku: "A001")
        create(:variant, product: product, sku: "A002")
        create(:product, name: 'zomg shirt', sku: "Z001")

        click_nav "Products"
        expect(page).to have_content("apache baseball cap")
        expect(page).to have_content("zomg shirt")
        expect(page).to have_css('#listing_products > tbody > tr', count: 2)

        fill_in "SKU", with: "A"
        click_button 'Search'
        expect(page).to have_content("apache baseball cap")
        expect(page).not_to have_content("zomg shirt")
        expect(page).to have_css('#listing_products > tbody > tr', count: 1)

        # Sort by master price
        click_on 'Master Price'
        expect(page).to have_css('.sort_link.asc', text: 'Master Price')
        expect(page).to have_content("apache baseball cap")
        expect(page).not_to have_content("zomg shirt")
        expect(page).to have_css('#listing_products > tbody > tr', count: 1)
      end
    end

    context "creating a new product" do
      before(:each) do
        @shipping_category = create(:shipping_category)
        click_nav "Products"
        click_on "New Product"
      end

      it "should allow an admin to create a new product", js: true do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        fill_in "product_available_on", with: "2012/01/24"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        expect(page).to have_content("successfully created!")
        click_button "Update"
        expect(page).to have_content("successfully updated!")
      end

      it "disables the button at submit", :js do
        page.execute_script "$('form').submit(function(e) { e.preventDefault()})"
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        fill_in "product_available_on", with: "2012/01/24"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"

        expect(page).to have_button("Create", disabled: true)
      end

      it "should show validation errors", js: false do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        click_button "Create"
        expect(page).to have_content("Shipping category can't be blank")
      end

      context "using a locale with a different decimal format " do
        before do
          # change English locale’s separator and delimiter to match 19,99 format
          I18n.backend.store_translations(:en,
            number: {
              currency: {
                format: {
                  separator: ",",
                  delimiter: "."
                }
              }
            })
        end

        after do
          # revert changes to English locale
          I18n.backend.store_translations(:en,
            number: {
              currency: {
                format: {
                  separator: ".",
                  delimiter: ","
                }
              }
            })
        end

        it "should show localized price value on validation errors", js: true do
          fill_in "Name", with: " "
          select @shipping_category.name, from: "product_shipping_category_id"
          fill_in "product_price", with: "19,99"
          click_button "Create"
          expect(page).to have_content("Name can't be blank")
          expect(page).to have_field('product_price', with: '19,99')
        end
      end

      # Regression test for https://github.com/spree/spree/issues/2097
      it "can set the count on hand to a null value", js: true do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_price", with: "100"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        expect(page).to have_content("successfully created!")
        click_button "Update"
        expect(page).to have_content("successfully updated!")
      end
    end

    context "cloning a product", js: true do
      it "should allow an admin to clone a product" do
        create(:product)

        click_nav "Products"
        within_row(1) do
          click_icon :copy
        end

        expect(page).to have_content("Product has been cloned")
      end

      context "cloning a deleted product" do
        it "should allow an admin to clone a deleted product" do
          create(:product, name: "apache baseball cap")

          click_nav "Products"
          check "Show Deleted"
          click_button "Search"

          expect(page).to have_content("apache baseball cap")

          within_row(1) do
            click_icon :copy
          end

          expect(page).to have_content("Product has been cloned")
        end
      end
    end

    context 'updating a product', js: true do
      let(:product) { create(:product) }

      it 'should parse correctly available_on' do
        visit spree.admin_product_path(product)
        fill_in "product_available_on", with: "2012/12/25"
        click_button "Update"
        expect(page).to have_content("successfully updated!")
        expect(Spree::Product.last.available_on).to eq('Tue, 25 Dec 2012 00:00:00 UTC +00:00')
      end
    end

    context 'deleting a product', js: true do
      let!(:product) { create(:product) }

      it "product details are still viewable" do
        visit spree.admin_products_path

        expect(page).to have_content(product.name)
        accept_alert do
          click_icon :trash
        end

        expect(page).to have_no_content(product.name)

        # This will show our deleted product
        check "Show Deleted"
        click_button "Search"
        click_link product.name
        expect(page).to_not have_field('Master Price')
        expect(page).to_not have_content('Images')
        expect(page).to_not have_content('Prices')
        expect(page).to_not have_content('Product Properties')
      end
    end
  end

  context 'with only product permissions' do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:try_spree_current_user).and_return(nil)
    end

    custom_authorization! do |_user|
      can [:admin, :update, :index, :read], Spree::Product
    end
    let!(:product) { create(:product) }

    it "should only display accessible links on index" do
      visit spree.admin_products_path
      expect(page).to have_link('Products')
      expect(page).not_to have_link('Option Types')
      expect(page).not_to have_link('Properties')

      expect(page).not_to have_link('New Product')
      expect(page).not_to have_css('a.clone')
      expect(page).to have_css('a.edit')
      expect(page).not_to have_css('a.delete-resource')
    end

    it "should only display accessible links on edit" do
      visit spree.admin_product_path(product)

      # product tabs should be hidden
      expect(page).to have_link('Product Details')
      expect(page).not_to have_link('Images')
      expect(page).not_to have_link('Variants')
      expect(page).not_to have_link('Product Properties')
      expect(page).not_to have_link('Stock Management')

      # no create permission
      expect(page).not_to have_link('New Product')
    end
  end
end
