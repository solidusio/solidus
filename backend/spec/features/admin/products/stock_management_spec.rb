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
        @product = create(:product, name: 'apache baseball cap', price: 10)
        @product.variants.create!(sku: 'FOOBAR')
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
      expect(stock_item.count_on_hand).to eq 14
      expect(stock_item.stock_movements.count).to eq 1
      expect(stock_item.stock_movements.first.quantity).to eq 4
    end

    it "can create a negative stock adjustment", js: true do
      adjust_count_on_hand('4')
      stock_item.reload
      expect(stock_item.count_on_hand).to eq 4
      expect(stock_item.stock_movements.count).to eq 1
      expect(stock_item.stock_movements.first.quantity).to eq(-6)
    end

    def adjust_count_on_hand(count_on_hand)
      within('.variant-stock-items', text: variant.sku) do
        within('tr', text: stock_item.stock_location.name) do
          click_icon :edit
          find(:css, "input[type='number']").set(count_on_hand)
          click_icon :check
        end
      end
      expect(page).to have_content('Updated successfully')
    end

    context "with multiple stock locations" do
      before do
        create(:stock_location, name: 'Other location', propagate_all_variants: false)
      end

      it "can add stock items to other stock locations", js: true do
        visit current_url
        within('.variant-stock-items', text: variant.sku) do
          fill_in "variant-count-on-hand-#{variant.id}", with: '3'
          targetted_select2_search "Other location", from: "#s2id_variant-stock-location-#{variant.id}"
          click_icon(:plus)
        end
        expect(page).to have_content('Created successfully')
      end
    end
  end
end
