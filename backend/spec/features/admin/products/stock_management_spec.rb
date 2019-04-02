# frozen_string_literal: true

require 'spec_helper'

describe "Product Stock", type: :feature do
  stub_authorization!

  before(:each) do
    visit spree.admin_path
  end

  context "given a product with a variant and a stock location" do
    let!(:stock_location) { create(:stock_location, name: 'Default') }
    let!(:product) { create(:product, name: 'apache baseball cap', price: 10) }
    let!(:variant) { create(:variant, product: product) }
    let(:stock_item) { variant.stock_items.find_by(stock_location: stock_location) }

    before do
      stock_location.stock_item(variant).update_column(:count_on_hand, 10)

      click_nav "Products"
      within_row(1) { click_icon :edit }
      click_link "Product Stock"
    end

    # Regression test for https://github.com/spree/spree/issues/3304
    # It is OK to still render the stock page, ensure no errors in this case
    context "with no stock location" do
      before do
        Spree::StockLocation.destroy_all
        find_by_id('content-header').click_link('Products')
        within_row(1) do
          click_icon :edit
        end
        click_link "Product Stock"
      end

      it "renders" do
        expect(page).to have_content('Productsapache baseball cap')
        expect(page.current_url).to match("admin/products/apache-baseball-cap/stock")
      end
    end

    it "can create a positive stock adjustment", js: true do
      adjust_count_on_hand('14')
      stock_item.reload
      expect(stock_item.count_on_hand).to eq 24
      expect(stock_item.stock_movements.count).to eq 1
      expect(stock_item.stock_movements.first.quantity).to eq 14
    end

    it "can create a negative stock adjustment", js: true do
      adjust_count_on_hand('-4')
      stock_item.reload
      expect(stock_item.count_on_hand).to eq 6
      expect(stock_item.stock_movements.count).to eq 1
      expect(stock_item.stock_movements.first.quantity).to eq(-4)
    end

    it "can toggle backorderable", js: true do
      toggle_backorderable(value: false)

      click_link "Product Stock"
      within("tr#spree_variant_#{variant.id}") do
        expect(find(:css, "input[type='checkbox']")).not_to be_checked
      end
    end

    def adjust_count_on_hand(count_on_hand)
      within("tr#spree_variant_#{variant.id}") do
        find(:css, "input[type='number']").set(count_on_hand)
        click_icon :check
      end
      expect(page).to have_content('Updated Successfully')
    end

    def toggle_backorderable(value: true)
      within("tr#spree_variant_#{variant.id}") do
        find(:css, "input[type='checkbox']").set(value)
        click_icon :check
      end
      expect(page).to have_content('Updated Successfully')
    end

    context "with stock locations that don't have stock items for variant yet" do
      before do
        create(:stock_location, name: 'Other location', propagate_all_variants: false)
      end

      it "can add stock items to other stock locations", js: true do
        visit current_url
        within('.variant-stock-items', text: variant.sku) do
          fill_in "variant-count-on-hand-#{variant.id}", with: '3'
          select "Other location", from: "stock_location_id"
          click_icon(:plus)
        end
        expect(page).to have_content('Created successfully')
      end
    end
  end
end
