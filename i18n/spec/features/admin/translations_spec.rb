require 'spec_helper'

describe "Product Translations tab" do
  let(:product) { create(:product) }

  stub_authorization!

  context "fills in product fields", js: true do
    before do
      visit spree.admin_product_path(product)
      reset_spree_preferences
      Spree::Config.all_locales = ['en', 'es']
      Spree::Config.supported_locales = ['en', 'es']
    end

    it "clicks on translation tab" do
      click_on "Translations"
      within "#attr_fields" do
        fill_in first("input[type='text']")["name"], with: "US product"
      end

      click_on "Update"
    end
  end
end
