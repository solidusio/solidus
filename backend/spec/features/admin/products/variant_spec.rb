# frozen_string_literal: true

require 'spec_helper'

describe "Variants", type: :feature do
  stub_authorization!

  let(:product) { create(:product_with_option_types, price: "1.99", cost_price: "1.00", weight: "2.5", height: "3.0", width: "1.0", depth: "1.5") }

  context "creating a new variant" do
    it "should allow an admin to create a new variant" do
      product.options.each do |option|
        create(:option_value, option_type: option.option_type)
      end

      visit spree.admin_path
      click_nav "Products"
      within_row(1) { click_icon :edit }
      click_link "Variants"
      click_on "New Variant"
      expect(page).to have_field('variant_price', with: "1.99")
      expect(page).to have_field('variant_cost_price', with: "1.00")
      expect(page).to have_field('variant_weight', with: "2.50")
      expect(page).to have_field('variant_height', with: "3.00")
      expect(page).to have_field('variant_width', with: "1.00")
      expect(page).to have_field('variant_depth', with: "1.50")
      expect(page).to have_select('variant[tax_category_id]')
    end
  end

  context "listing variants" do
    context "currency displaying" do
      context "using Russian Rubles" do
        before do
          stub_spree_preferences(currency: "RUB")
        end

        let!(:variant) do
          create(:variant, product: product, price: 19.99)
        end

        # Regression test for https://github.com/spree/spree/issues/2737
        context "uses руб as the currency symbol" do
          it "on the products listing page" do
            visit spree.admin_product_variants_path(product)
            within_row(1) { expect(page).to have_content("19.99 ₽") }
          end
        end
      end
    end
  end

  context "editing existent variant" do
    let!(:variant) { create(:variant, product: product) }

    context "if product has an option type" do
      let!(:option_type) { create(:option_type) }
      let!(:option_value) { create(:option_value, option_type: option_type) }

      before do
        product.option_types << option_type
        variant.option_values << option_value
      end

      it "page has a field for editing the option value", js: true do
        visit spree.edit_admin_product_variant_path(product, variant)
        expect(page).to have_css("label", text: option_type.presentation)
        expect(page).to have_select('Size', selected: 'S')
      end
    end
  end

  context "deleting a variant", js: true do
    let!(:variant) { create(:variant, product: product) }
    let!(:option_type) { create(:option_type) }
    let!(:option_value) { create(:option_value, option_type: option_type) }

    it "can delete a variant" do
      visit spree.admin_product_variants_path(product)
      within 'tr', text: 'Size: S' do
        accept_alert do
          click_icon :trash
        end
      end

      expect(page).to have_no_text('Size: S')
    end
  end
end
