module Spree
  RSpec.describe Product, type: :model do
    let(:product) { create(:product) }
    let(:taxon) { create(:taxon) }

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
      expect(product.taxons).to include(taxon)
    end
  end
end
