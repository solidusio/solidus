require 'spec_helper'

describe 'Pricing' do
  stub_authorization!

  let(:product) { create(:product) }

  before do
    visit spree.edit_admin_product_path(product)
  end

  it 'has a Prices tab' do
    within(".tabs") do
      expect(page).to have_link("Prices")
    end
  end

  context "in the prices tab" do
    let!(:country) { create :country, iso: "DE" }
    let(:master_price) { product.master.default_price }
    let!(:other_price) { product.master.prices.create(amount: 34.56, currency: "RUB", country_iso: "DE") }

    before do
      visit spree.admin_product_prices_path(product)
    end

    it 'displays a table with the prices' do
      expect(page).to have_content(product.name)
      within(".tabs .active") do
        expect(page).to have_content("Prices")
      end

      within('table.prices') do
        expect(page).to have_content("$19.99")
        expect(page).to have_content("USD")
        expect(page).to have_content("34.56 ₽")
        expect(page).to have_content("RUB")
        expect(page).to have_content("Master")
        expect(page).to have_content("Any Country")
        expect(page).to have_content("Germany")
      end
    end

    context "searching" do
      let(:variant) { create(:variant, price: 20) }
      let(:product) { variant.product }

      before do
        product.master.update(price: 49.99)
      end

      it 'has a working table filter' do
        expect(page).to have_selector("#table-filter")
        within "#table-filter" do
          within "fieldset legend" do
            expect(page).to have_content("Search")
          end
        end
        select variant.options_text, from: "q_variant_id_eq"
        click_button "Filter Results"
        expect(page).to have_content("20")
        expect(page).to_not have_content("49.99")
      end
    end

    context "deleting", js: true do
      let(:product) { create(:product, price: 65.43) }
      let!(:variant) { product.master }
      let!(:other_price) { product.master.prices.create(amount: 34.56, currency: "EUR") }

      it "will delete the non-default price" do
        within "#spree_price_#{other_price.id}" do
          accept_alert do
            click_icon :trash
          end
        end
        expect(page).to have_content("Price has been successfully removed")
      end

      it "does not break when default price is deleted" do
        within "#spree_price_#{variant.default_price.id}" do
          accept_alert do
            click_icon :trash
          end
        end
        expect(page).to have_content("Price has been successfully removed")
        visit spree.admin_products_path
        expect(page).to have_selector("#spree_product_#{product.id}")
      end
    end
  end
end
