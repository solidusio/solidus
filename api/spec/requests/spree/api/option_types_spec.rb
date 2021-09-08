# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::OptionTypesController, type: :request do
    let(:attributes) { [:id, :name, :position, :presentation] }
    let!(:option_value) { create(:option_value) }
    let!(:option_type) { option_value.option_type }

    before do
      stub_authentication!
    end

    def check_option_values(option_values)
      expect(option_values.count).to eq(1)
      expect(option_values.first).to have_attributes([:id, :name, :presentation,
                                                      :option_type_name, :option_type_id])
    end

    it "can list all option types" do
      get spree.api_option_types_path
      expect(json_response.count).to eq(1)
      expect(json_response.first).to have_attributes(attributes)

      check_option_values(json_response.first["option_values"])
    end

    it "can search for an option type" do
      create(:option_type, name: "buzz")
      get spree.api_option_types_path, params: { q: { name_cont: option_type.name } }
      expect(json_response.count).to eq(1)
      expect(json_response.first).to have_attributes(attributes)
    end

    it "can retrieve a list of specific option types" do
      option_type_one = create(:option_type)
      create(:option_type)
      get spree.api_option_types_path, params: { ids: "#{option_type.id},#{option_type_one.id}" }
      expect(json_response.count).to eq(2)

      check_option_values(json_response.first["option_values"])
    end

    it "can list a single option type" do
      get spree.api_option_type_path(option_type)
      expect(json_response).to have_attributes(attributes)
      check_option_values(json_response["option_values"])
    end

    it "cannot create a new option type" do
      post spree.api_option_types_path, params: {
        option_type: {
          name: "Option Type",
          presentation: "Option Type"
        }
      }
      assert_unauthorized!
    end

    it "cannot alter an option type" do
      original_name = option_type.name
      put spree.api_option_type_path(option_type), params: {
        option_type: {
          name: "Option Type"
        }
      }
      assert_not_found!
      expect(option_type.reload.name).to eq(original_name)
    end

    it "cannot delete an option type" do
      delete spree.api_option_type_path(option_type)
      assert_not_found!
      expect { option_type.reload }.not_to raise_error
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can create an option type" do
        post spree.api_option_types_path, params: {
          option_type: {
            name: "Option Type",
            presentation: "Option Type"
          }
        }
        expect(json_response).to have_attributes(attributes)
        expect(response.status).to eq(201)
      end

      it "cannot create an option type with invalid attributes" do
        post spree.api_option_types_path, params: { option_type: {} }
        expect(response.status).to eq(422)
      end

      it "can update an option type" do
        put spree.api_option_type_path(option_type.id), params: { option_type: { name: "Option Type" } }
        expect(response.status).to eq(200)

        option_type.reload
        expect(option_type.name).to eq("Option Type")
      end

      it "cannot update an option type with invalid attributes" do
        put spree.api_option_type_path(option_type.id), params: { option_type: { name: "" } }
        expect(response.status).to eq(422)
      end

      it "can delete an option type" do
        delete spree.api_option_type_path(option_type.id)
        expect(response.status).to eq(204)
      end
    end
  end
end
