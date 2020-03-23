# frozen_string_literal: true

require 'spec_helper'

feature 'Promotion with product rule', js: true do
  stub_authorization!

  given!(:product) { create :product, name: "BlamCo Mac & Cheese", sku: "PRODUCT_SKU" }
  given!(:variant) { create :variant, sku: "VARIANT_SKU", product: product }
  given!(:option_value) { variant.option_values.first }

  given(:promotion) { create :promotion }

  def add_promotion_rule_of_type(type)
    select type, from: "Discount Rules"
    within("#rules_container") { click_button "Add" }
  end

  background do
    visit spree.edit_admin_promotion_path(promotion)
    add_promotion_rule_of_type("Product(s)")
  end

  it "can select by product sku" do
    select2_search product.name, from: "Choose products", search: "PRODUCT_SKU"
  end

  it "can select by variant sku" do
    select2_search product.name, from: "Choose products", search: "VARIANT_SKU"
  end

  it "can select by product name" do
    select2_search product.name, from: "Choose products"
  end
end
