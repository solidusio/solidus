# frozen_string_literal: true

require "rails_helper"

module Spree
  RSpec.describe Spree::ProductDuplicator, type: :model do
    let(:product) { create(:product, properties: [create(:property, name: "MyProperty")]) }
    let!(:duplicator) { Spree::ProductDuplicator.new(product) }

    let(:image) { File.open(Spree::Core::Engine.root.join("lib", "spree", "testing_support", "fixtures", "blank.jpg")) }
    let(:params) { {viewable_id: product.master.id, viewable_type: "Spree::Variant", attachment: image, alt: "position 1", position: 1} }

    before do
      Spree::Image.create(params)
    end

    it "will duplicate the product" do
      expect { duplicator.duplicate }.to change { Spree::Product.count }.by(1)
    end

    context "when image duplication enabled" do
      it "will duplicate the product images" do
        expect { duplicator.duplicate }.to change { Spree::Image.count }.by(1)
      end
    end

    context "when image duplication disabled" do
      let!(:duplicator) { Spree::ProductDuplicator.new(product, false) }

      it "will not duplicate the product images" do
        expect { duplicator.duplicate }.to change { Spree::Image.count }.by(0)
      end
    end

    context "image duplication default" do
      context "when default is set to true" do
        it "clones images if no flag passed to initializer" do
          expect { duplicator.duplicate }.to change { Spree::Image.count }.by(1)
        end
      end

      context "when default is set to false" do
        before do
          ProductDuplicator.clone_images_default = false
        end

        after do
          ProductDuplicator.clone_images_default = true
        end

        it "does not clone images if no flag passed to initializer" do
          expect { ProductDuplicator.new(product).duplicate }.to change { Spree::Image.count }.by(0)
        end
      end
    end

    context "product attributes" do
      let!(:new_product) { duplicator.duplicate }

      it "will set an unique name" do
        expect(new_product.name).to eql "COPY OF #{product.name}"
      end

      it "will set the same price" do
        expect(new_product.reload.price).to eql product.price
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
      let(:option_value1) { create(:option_value, name: "OptionValue1", option_type:) }
      let(:option_value2) { create(:option_value, name: "OptionValue2", option_type:) }

      let!(:variant1) { create(:variant, product:, option_values: [option_value1]) }
      let!(:variant2) { create(:variant, product:, option_values: [option_value2]) }

      it "will duplciate the variants" do
        # will change the count by 3, since there will be a master variant as well
        expect { duplicator.duplicate }.to change { Spree::Variant.count }.by(3)
      end

      it "will not duplicate the option values" do
        expect { duplicator.duplicate }.to change { Spree::OptionValue.count }.by(0)
      end

      it "will duplicate the variants after initial duplicate is discarded" do
        duplicator.duplicate.discard
        expect { duplicator.duplicate }.to change { Spree::Variant.count }.by(3)
      end
    end
  end
end
