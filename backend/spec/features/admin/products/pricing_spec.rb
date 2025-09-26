# frozen_string_literal: true

require "spec_helper"

describe "Pricing" do
  stub_authorization!

  let(:product) { create(:product) }

  before do
    visit spree.edit_admin_product_path(product)
  end

  it "has a Prices tab" do
    within(".tabs") do
      expect(page).to have_link("Prices")
    end
  end

  context "in the prices tab" do
    let!(:country) { create :country, iso: "DE" }
    let(:master_price) { product.master.default_price }
    let!(:other_price) { product.master.prices.create(amount: 34.56, currency: "RUB", country_iso: "DE") }

    subject do
      visit spree.admin_product_prices_path(product)
    end

    it "displays a table with the prices" do
      subject
      expect(page).to have_content(product.name)
      within(".tabs .active") do
        expect(page).to have_content("Prices")
      end

      within("table.master_prices") do
        expect(page).to have_content("$19.99")
        expect(page).to have_content("USD")
        expect(page).to have_content("34.56 ₽")
        expect(page).to have_content("RUB")
        expect(page).to have_content("Any Country")
        expect(page).to have_content("Germany")
      end
    end

    context "when the user can edit prices" do
      custom_authorization! do |_user|
        can :edit, Spree::Price
      end

      it "shows edit links" do
        subject

        expect(page).to have_selector('a[data-action="edit"]')
      end
    end

    context "when the user cannot edit prices" do
      custom_authorization! do |_user|
        cannot :edit, Spree::Price
      end

      it "doesn't show edit links" do
        subject

        expect(page).not_to have_selector('a[data-action="edit"]')
      end
    end

    context "searching" do
      let(:variant) { create(:variant, price: 20) }
      let(:product) { variant.product }

      before do
        product.master.update(price: 49.99)
      end

      it "has a working table filter" do
        subject
        expect(page).to have_selector("#table-filter")
        within "#table-filter" do
          within "fieldset legend" do
            expect(page).to have_content("Search")
          end
        end
        select variant.options_text, from: "q_variant_id_eq", exact: false
        click_button "Filter Results"
        expect(page).to have_content("20")
        expect(page).to_not have_content("49.99")
      end
    end

    context "pagination" do
      let(:product) do
        create(:product).tap do |product|
          product.master.prices << create(:price)
        end
      end

      let!(:variants) do
        v = []
        3.times do |i|
          v << create(:variant, price: i * 10, product:)
        end
        v
      end

      before do
        allow(Spree::Config).to receive(:admin_variants_per_page) { 1 }
      end

      it "paginates products and variants independently" do
        subject
        within '[data-hook="variant_prices_table"] > nav:first-of-type > .pagination' do
          click_link "2"
        end
        product_prices = product.prices.for_master.order(:variant_id, :country_iso, :currency)
        expect(page).to have_content(product_prices[0].display_amount)
        expect(page).to_not have_content(product_prices[1].display_amount)
        expect(page).to_not have_content(product_prices[2].display_amount)
        variant_prices = product.prices.for_variant.order(:variant_id, :country_iso, :currency)
        expect(page).to_not have_content(variant_prices[0].display_price)
        expect(page).to have_content(variant_prices[1].display_price)
        expect(page).to_not have_content(variant_prices[2].display_price)
      end
    end

    context "editing" do
      let(:product) { create(:product, price: 123.99) }
      let!(:variant) { product.master }
      let!(:other_price) { product.master.prices.create(amount: 34.56, currency: "EUR") }

      it "has a working edit page" do
        subject
        within "#spree_price_#{product.master.prices.first.id}" do
          click_icon :edit
        end
        expect(page).to have_content("Edit Price")

        within("#price_price_field") do
          expect(page).to have_field("price_price", with: "123.99")
        end

        fill_in "price_price", with: 999.99
        click_button "Update"
        expect(page).to have_content("Price has been successfully updated!")
        expect(page).to have_content("$999.99")
        expect(page).to have_content("€34.56")
      end

      it "will not reset the currency to default" do
        subject
        within "#spree_price_#{other_price.id}" do
          click_icon :edit
        end
        expect(page).to have_content("Edit Price")
        expect(page).to_not have_field("price_currency", with: "USD")
        within("#price_price_field") do
          expect(page).to have_css(".number-with-currency-addon", text: "EUR")
        end
      end
    end

    context "deleting", js: true do
      let(:product) { create(:product, price: 65.43) }
      let!(:variant) { product.master }
      let!(:other_price) { product.master.prices.create(amount: 34.56, currency: "EUR") }

      it "will delete the non-default price" do
        subject
        within "#spree_price_#{other_price.id}" do
          accept_alert do
            click_icon :trash
          end
        end
        expect(page).to have_content("Price has been successfully removed")
      end

      it "does not break when default price is deleted" do
        subject
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
