# frozen_string_literal: true

require 'rails_helper'
require 'spree/core/product_filters'

RSpec.describe 'product filters', type: :model do
  # Regression test for https://github.com/spree/spree/issues/1709
  context 'finds products filtered by brand' do
    let(:product) { create(:product) }
    before do
      Spree::Property.create!(name: "brand", presentation: "brand")
      product.set_property("brand", "Nike")
    end

    it "does not attempt to call value method on Arel::Table" do
      Spree::Core::ProductFilters.brand_filter
    end

    it "can find products in the 'Nike' brand" do
      expect(Spree::Product.brand_any("Nike")).to include(product)
    end
    it "sorts products without brand specified" do
      product.set_property("brand", "Nike")
      create(:product).set_property("brand", nil)
      Spree::Core::ProductFilters.brand_filter[:labels]
    end
  end
end
