require 'spec_helper'

module Spree
  describe Product do
    # Regression test for #309
    it "duplicates translations" do
      product = create(:product)
      original_count = product.translations.count
      new_product = product.duplicate
      expect(new_product.translations).not_to be_blank
      expect(product.translations.count).to eq original_count
    end
  end
end