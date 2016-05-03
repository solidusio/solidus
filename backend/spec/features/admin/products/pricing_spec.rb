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
    let(:master_price) { product.master.default_price }
    let!(:other_price) { product.master.prices.create(amount: 34.56, currency: "RUB") }

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
        expect(page).to have_content("Master Variant")
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
  end
end
