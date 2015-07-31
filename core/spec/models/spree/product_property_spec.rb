require 'spec_helper'

describe Spree::ProductProperty, :type => :model do

  context "validations" do
    # Only MySQL and stores that were migrated prior to the Rails 4.1(?) upgrade
    # have length limitations on "value".
    if Spree::ProductProperty.columns_hash['value'].limit
      it "should validate length of value" do
        pp = create(:product_property)
        overflow_length = Spree::ProductProperty.columns_hash['value'].limit + 1
        pp.value = "x" * overflow_length
        expect(pp).not_to be_valid
      end
    end
  end

  context "touching" do
    it "should update product" do
      pp = create(:product_property)
      expect(pp.product).to receive(:touch)
      pp.touch
    end
  end
end
