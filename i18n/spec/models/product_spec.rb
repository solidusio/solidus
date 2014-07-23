require 'spec_helper'

module Spree
  describe Product do
    let(:product) { FactoryGirl.create(:product) }
    let(:taxon) { FactoryGirl.create(:taxon) }

    # Regression test for #309
    it "duplicates translations" do
      original_count = product.translations.count
      new_product = product.duplicate
      expect(new_product.translations).not_to be_blank
      expect(product.translations.count).to eq original_count
    end

    # Regression test for #433
    it "allow saving a product with taxons" do
      product.taxons << taxon
      product.taxons.should include(taxon)
    end
  end
end
