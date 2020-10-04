# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/protect_product_actions'

module Spree
  describe Spree::Api::ProductPropertiesController, type: :request do
    let!(:product) { create(:product) }
    let!(:property_1) { product.product_properties.create(property_name: "My Property 1", value: "my value 1", position: 0) }
    let!(:property_2) { product.product_properties.create(property_name: "My Property 2", value: "my value 2", position: 1) }

    let(:attributes) { [:id, :product_id, :property_id, :value, :property_name] }
    let(:resource_scoping) { { product_id: product.to_param } }

    before do
      stub_authentication!
    end

    context "if product is deleted" do
      before do
        product.update_column(:deleted_at, 1.day.ago)
      end

      it "can not see a list of product properties" do
        get spree.api_product_product_properties_path(product)
        expect(response.status).to eq(404)
      end
    end

    it "can see a list of all product properties" do
      get spree.api_product_product_properties_path(product)
      expect(json_response["product_properties"].count).to eq 2
      expect(json_response["product_properties"].first).to have_attributes(attributes)
    end

    it "can control the page size through a parameter" do
      get spree.api_product_product_properties_path(product), params: { per_page: 1 }
      expect(json_response['product_properties'].count).to eq(1)
      expect(json_response['current_page']).to eq(1)
      expect(json_response['pages']).to eq(2)
    end

    it 'can query the results through a parameter' do
      Spree::ProductProperty.last.update_attribute(:value, 'loose')
      property = Spree::ProductProperty.last
      get spree.api_product_product_properties_path(product), params: { q: { value_cont: 'loose' } }
      expect(json_response['count']).to eq(1)
      expect(json_response['product_properties'].first['value']).to eq property.value
    end

    it "can see a single product_property" do
      get spree.api_product_product_property_path(product, property_1.property_name)
      expect(json_response).to have_attributes(attributes)
    end

    it "can learn how to create a new product property" do
      get spree.new_api_product_product_property_path(product)
      expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
      expect(json_response["required_attributes"]).to be_empty
    end

    it "cannot create a new product property if not an admin" do
      post spree.api_product_product_properties_path(product), params: { product_property: { property_name: "My Property 3" } }
      assert_unauthorized!
    end

    it "cannot update a product property" do
      put spree.api_product_product_property_path(product, property_1.property_name), params: { product_property: { value: "my value 456" } }
      assert_unauthorized!
    end

    it "cannot delete a product property" do
      delete spree.api_product_product_property_path(product, property_1.property_name)
      assert_unauthorized!
      expect { property_1.reload }.not_to raise_error
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can create a new product property" do
        expect do
          post spree.api_product_product_properties_path(product), params: { product_property: { property_name: "My Property 3", value: "my value 3" } }
        end.to change(product.product_properties, :count).by(1)
        expect(json_response).to have_attributes(attributes)
        expect(response.status).to eq(201)
      end

      it "can update a product property" do
        put spree.api_product_product_property_path(product, property_1.property_name), params: { product_property: { value: "my value 456" } }
        expect(response.status).to eq(200)
      end

      it "can delete a product property" do
        delete spree.api_product_product_property_path(product, property_1.property_name)
        expect(response.status).to eq(204)
        expect { property_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context 'when product property does not exist' do
        it 'cannot update because is not found' do
          put spree.api_product_product_property_path(product, 'no property'), params: { product_property: { value: "my value 456" } }
          expect(response.status).to eq(404)
        end

        it 'cannot delete because is not found' do
          delete spree.api_product_product_property_path(product, 'no property')
          expect(response.status).to eq(404)
        end
      end
    end

    context "with product identified by id" do
      it "can see a list of all product properties" do
        get spree.api_product_product_properties_path(product)
        expect(json_response["product_properties"].count).to eq 2
        expect(json_response["product_properties"].first).to have_attributes(attributes)
      end

      it "can see a single product_property by id" do
        get spree.api_product_product_property_path(product, property_1.id)
        expect(json_response).to have_attributes(attributes)
      end
    end
  end
end
