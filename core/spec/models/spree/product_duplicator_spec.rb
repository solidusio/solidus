# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Spree::ProductDuplicator, type: :model do
    let(:product) { create(:product, properties: [create(:property, name: "MyProperty")]) }
    let!(:duplicator) { Spree::ProductDuplicator.new(product) }

    it "will duplicate the product" do
      expect{ duplicator.duplicate }.to change{ Spree::Product.count }.by(1)
    end

    context "product attributes" do
      let!(:new_product) { duplicator.duplicate }

      it "will set an unique name" do
        expect(new_product.name).to eql "COPY OF #{product.name}"
      end

      it "will set an unique sku" do
        expect(new_product.sku).to include "COPY OF SKU"
      end

      it "copied the properties" do
        expect(new_product.product_properties.count).to be 1
        expect(new_product.product_properties.first.property.name).to eql "MyProperty"
      end
    end

    context "with variants" do
      let(:option_type) { create(:option_type, name: "MyOptionType") }
      let(:option_value1) { create(:option_value, name: "OptionValue1", option_type: option_type) }
      let(:option_value2) { create(:option_value, name: "OptionValue2", option_type: option_type) }

      let!(:variant1) { create(:variant, product: product, option_values: [option_value1]) }
      let!(:variant2) { create(:variant, product: product, option_values: [option_value2]) }

      it "will duplciate the variants" do
        # will change the count by 3, since there will be a master variant as well
        expect{ duplicator.duplicate }.to change{ Spree::Variant.count }.by(3)
      end

      it "will not duplicate the option values" do
        expect{ duplicator.duplicate }.to change{ Spree::OptionValue.count }.by(0)
      end
    end
  end
end
