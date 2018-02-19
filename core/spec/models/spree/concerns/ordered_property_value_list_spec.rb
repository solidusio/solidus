# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderedPropertyValueList do
  #
  # Using ProductProperty as a subject
  # since it includes OrderedPropertyValueList
  #

  context 'positioning' do
    let(:product_1) { create(:product) }
    let!(:property_1) { create(:product_property, product: product_1) }
    let!(:property_2) { create(:product_property, product: product_1) }

    let(:product_2) { create(:product) }
    let!(:property_3) { create(:product_property, product: product_2) }
    let!(:property_4) { create(:product_property, product: product_2) }

    before do
      property_1.update_attribute(:position, 0)
      property_2.update_attribute(:position, 1)
      property_3.update_attribute(:position, 0)
      property_4.update_attribute(:position, 1)
    end

    it 'scopes position to the product' do
      expect(property_1.reload.position).to eq(0)
      expect(property_2.reload.position).to eq(1)
      expect(property_3.reload.position).to eq(0)
      expect(property_4.reload.position).to eq(1)
    end
  end

  context "validations" do
    let(:product_property) { create(:product_property) }

    # Only MySQL stores or stores that were migrated prior to the Rails 4.2
    # upgrade have length limitations on "value":
    # > The PostgreSQL and SQLite adapters no longer add a default limit of 255
    # > characters on string columns.
    # http://guides.rubyonrails.org/4_2_release_notes.html#active-record-notable-changes
    # https://github.com/rails/rails/pull/14579
    if Spree::ProductProperty.columns_hash['value'].limit
      it "should validate length of value" do
        overflow_length = Spree::ProductProperty.columns_hash['value'].limit + 1
        product_property.value = "x" * overflow_length
        expect(product_property).not_to be_valid
      end
    end
  end
end
