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
    let!(:variant2) { create(:variant, product: product, track_inventory: false) }
    let(:stock_item) { variant.stock_items.find_by(stock_location: stock_location) }
    let(:stock_item2) { variant2.stock_items.find_by(stock_location: stock_location) }

    before do
      stock_location.stock_item(variant).update_column(:count_on_hand, 10)
      stock_location.stock_item(variant2).update_column(:count_on_hand, 13)

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

    it "contains a link to recent stock movements", js: true do
      expect(page).to have_link(nil, href: "/admin/stock_locations/#{stock_location.id}/stock_movements?q%5Bvariant_sku_eq%5D=#{variant.sku}")
    end

    it "can create a positive stock adjustment", js: true do
      adjust_count_on_hand(variant.id, '14')
      stock_item.reload
      expect(stock_item.count_on_hand).to eq 24
      expect(stock_item.stock_movements.count).to eq 1
      expect(stock_item.stock_movements.first.quantity).to eq 14
    end

    it "can create a negative stock adjustment", js: true do
      adjust_count_on_hand(variant.id, '-4')
      stock_item.reload
      expect(stock_item.count_on_hand).to eq 6
      expect(stock_item.stock_movements.count).to eq 1
      expect(stock_item.stock_movements.first.quantity).to eq(-4)
    end

    it "can toggle backorderable", js: true do
      toggle_backorderable(variant.id, value: false)

      click_link "Product Stock"
      within("tr#spree_variant_#{variant.id}") do
        expect(find(:css, "input[type='checkbox']")).not_to be_checked
      end
    end

    def adjust_count_on_hand(variant_id, count_on_hand)
      within("tr#spree_variant_#{variant_id}") do
        find(:css, "input[type='number']").set(count_on_hand)
        click_icon :check
      end
      expect(page).to have_content('Updated Successfully')
    end

    def toggle_backorderable(variant_id, value: true)
      within("tr#spree_variant_#{variant_id}") do
        find(:css, "input[type='checkbox']").set(value)
        click_icon :check
      end
      expect(page).to have_content('Updated Successfully')
    end

    context "with two variants, one of which tracks inventory while the other doesn't" do
      it "allows modifying backorderable only on the variant which tracks inventory", js: true do
        expect(page).not_to have_css("tr#spree_variant_#{variant.id} input[name='backorderable'][disabled='disabled']")
        expect(page).to have_css("tr#spree_variant_#{variant2.id} input[name='backorderable'][disabled='disabled']")
      end

      it "allows modifying the count on hand only on the variant which tracks inventory", js: true do
        expect(page).not_to have_css("tr#spree_variant_#{variant.id} input[name='count_on_hand'][disabled='disabled']")
        expect(page).to have_css("tr#spree_variant_#{variant2.id} input[name='count_on_hand'][disabled='disabled']")

        find("tr#spree_variant_#{variant.id} input[name='count_on_hand']").hover
        expect(page).not_to have_text('"Track inventory" option disabled for this variant')

        find("tr#spree_variant_#{variant2.id} input[name='count_on_hand']").hover
        expect(page).to have_text('"Track inventory" option disabled for this variant')
      end
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
