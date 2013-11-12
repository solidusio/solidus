require 'spec_helper'

module Spree
  describe Product do
    # Regression test for #309
    it "duplicates translations" do
      product = FactoryGirl.create(:product)
      original_count = product.translations.count
      new_product = product.duplicate
      new_product.translations.should_not be_blank
      product.translations.count.should == original_count
    end
  end
end