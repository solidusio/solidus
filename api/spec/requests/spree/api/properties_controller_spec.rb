# frozen_string_literal: true

require 'spec_helper'
module Spree
  describe Spree::Api::PropertiesController, type: :request do
    let!(:property_1) { Property.create!(name: "foo", presentation: "Foo") }
    let!(:property_2) { Property.create!(name: "bar", presentation: "Bar") }

    let(:attributes) { [:id, :name, :presentation] }

    before do
      stub_authentication!
    end

    it "can see a list of all properties" do
      get spree.api_properties_path
      expect(json_response["properties"].count).to eq(2)
      expect(json_response["properties"].first).to have_attributes(attributes)
    end

    it "can control the page size through a parameter" do
      get spree.api_properties_path, params: { per_page: 1 }
      expect(json_response['properties'].count).to eq(1)
      expect(json_response['current_page']).to eq(1)
      expect(json_response['pages']).to eq(2)
    end

    it 'can query the results through a parameter' do
      get spree.api_properties_path, params: { q: { name_cont: 'ba' } }
      expect(json_response['count']).to eq(1)
      expect(json_response['properties'].first['presentation']).to eq property_2.presentation
    end

    it "retrieves a list of properties by id" do
      get spree.api_properties_path, params: { ids: [property_1.id] }
      expect(json_response["properties"].first).to have_attributes(attributes)
      expect(json_response["count"]).to eq(1)
    end

    it "retrieves a list of properties by ids string" do
      get spree.api_properties_path, params: { ids: [property_1.id, property_2.id].join(",") }
      expect(json_response["properties"].first).to have_attributes(attributes)
      expect(json_response["properties"][1]).to have_attributes(attributes)
      expect(json_response["count"]).to eq(2)
    end

    it "can see a single property" do
      get spree.api_property_path(property_1.id)
      expect(json_response).to have_attributes(attributes)
    end

    it "can see a property by name" do
      get spree.api_property_path(property_1.name)
      expect(json_response).to have_attributes(attributes)
    end

    it "can learn how to create a new property" do
      get spree.new_api_property_path
      expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
      expect(json_response["required_attributes"]).to be_empty
    end

    it "cannot create a new property if not an admin" do
      post spree.api_properties_path, params: { property: { name: "My Property 3" } }
      assert_unauthorized!
    end

    it "cannot update a property" do
      put spree.api_property_path(property_1.name), params: { property: { presentation: "my value 456" } }
      assert_unauthorized!
    end

    it "cannot delete a property" do
      delete spree.api_property_path(property_1.name)
      assert_unauthorized!
      expect { property_1.reload }.not_to raise_error
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can create a new property" do
        expect(Spree::Property.count).to eq(2)
        post spree.api_properties_path, params: { property: { name: "My Property 3", presentation: "my value 3" } }
        expect(json_response).to have_attributes(attributes)
        expect(response.status).to eq(201)
        expect(Spree::Property.count).to eq(3)
      end

      it "can update a property" do
        put spree.api_property_path(property_1.name), params: { property: { presentation: "my value 456" } }
        expect(response.status).to eq(200)
      end

      it "can delete a property" do
        delete spree.api_property_path(property_1.name)
        expect(response.status).to eq(204)
        expect { property_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
