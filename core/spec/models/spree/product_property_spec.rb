require 'spec_helper'

describe Spree::ProductProperty, :type => :model do

  context "validations" do
    # Only MySQL stores or stores that were migrated prior to the Rails 4.2
    # upgrade have length limitations on "value":
    # > The PostgreSQL and SQLite adapters no longer add a default limit of 255
    # > characters on string columns.
    # http://guides.rubyonrails.org/4_2_release_notes.html#active-record-notable-changes
    # https://github.com/rails/rails/pull/14579
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
