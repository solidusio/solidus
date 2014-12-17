# encoding: utf-8

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

    # Regression tests for #466
    describe ".like_any" do
      context "allow searching products through their translations" do
        before(:each) do
          I18n.locale = :"zh-CN"
        end

        it "with name" do
          product.translations.create locale: "zh-CN",
                                      name: "创意马克杯",
                                      description: "<p>一流工程师设计制造手工艺品</p>",
                                      meta_description: '顶尖工艺设计',
                                      meta_keywords: '工艺品'

          expect(Product.like_any([:name], ['创意'])).to include(product)
        end

        it "with name or description" do
          product.translations.create locale: "zh-CN",
                                      name: "创意马克杯",
                                      description: "<p>一流工程师设计制造手工艺品</p>",
                                      meta_description: '顶尖工艺设计',
                                      meta_keywords: '工艺品'

          expect(Product.like_any([:name, :description], ['手工艺品'])).to include(product)
        end
      end
    end
  end
end
