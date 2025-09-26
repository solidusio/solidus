# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe "Option values", type: :request do
    let(:attributes) { [:id, :name, :presentation, :option_type_name, :option_type_name] }
    let!(:option_value) { create(:option_value) }
    let!(:option_type) { option_value.option_type }

    before do
      stub_authentication!
    end

    context "without any option type scoping" do
      before do
        # Create another option value with a brand new option type
        create(:option_value, option_type: create(:option_type))
      end

      it "can retrieve a list of all option values" do
        get spree.api_option_values_path
        expect(json_response.count).to eq(2)
        expect(json_response.first).to have_attributes(attributes)
      end
    end

    context "filtering by product" do
      let(:product) { create(:product, option_types: [product_option_value.option_type]) }
      let(:product_option_value) { create(:option_value, presentation: "BLACK") }
      let!(:variant) { create(:variant, product:, option_values: [product_option_value]) }

      it "can filter by product" do
        get spree.api_option_values_path(q: {variants_product_id_eq: product.id})
        expect(json_response.count).to eq(1)
        expect(json_response.first["presentation"]).to eq("BLACK")
      end
    end

    context "for a particular option type" do
      let(:resource_scoping) { {option_type_id: option_type.id} }

      it "can list all option values" do
        get spree.api_option_values_path
        expect(json_response.count).to eq(1)
        expect(json_response.first).to have_attributes(attributes)
      end

      it "can search for an option type" do
        create(:option_value, name: "buzz")
        get spree.api_option_values_path, params: {q: {name_cont: option_value.name}}
        expect(json_response.count).to eq(1)
        expect(json_response.first).to have_attributes(attributes)
      end

      it "can retrieve a list of option types" do
        option_value_one = create(:option_value, option_type:)
        create(:option_value, option_type:)
        get spree.api_option_values_path, params: {ids: [option_value.id, option_value_one.id]}
        expect(json_response.count).to eq(2)
      end

      it "can list a single option value" do
        get spree.api_option_value_path(option_value.id)
        expect(json_response).to have_attributes(attributes)
      end

      it "cannot create a new option value" do
        post spree.api_option_type_option_values_path(option_type), params: {
          option_value: {
            name: "Option Value",
            presentation: "Option Value"
          }
        }
        assert_unauthorized!
      end

      it "cannot alter an option value" do
        original_name = option_type.name
        put spree.api_option_value_path(option_value.id), params: {
          id: option_type.id,
          option_value: {
            name: "Option Value"
          }
        }
        assert_not_found!
        expect(option_type.reload.name).to eq(original_name)
      end

      it "cannot delete an option value" do
        delete spree.api_option_value_path(option_value)
        assert_not_found!
        expect { option_type.reload }.not_to raise_error
      end

      context "as an admin" do
        sign_in_as_admin!

        it "can create an option value" do
          post spree.api_option_type_option_values_path(option_type), params: {
            option_value: {
              name: "Option Value",
              presentation: "Option Value"
            }
          }
          expect(json_response).to have_attributes(attributes)
          expect(response.status).to eq(201)
        end

        it "cannot create an option type with invalid attributes" do
          post spree.api_option_type_option_values_path(option_type), params: {option_value: {name: ""}}
          expect(response.status).to eq(422)
        end

        it "can update an option value" do
          put spree.api_option_value_path(option_value.id), params: {option_value: {
            name: "Option Value"
          }}
          expect(response.status).to eq(200)

          option_value.reload
          expect(option_value.name).to eq("Option Value")
        end

        it "permits the correct attributes" do
          expect_any_instance_of(Spree::Api::OptionValuesController).to receive(:permitted_option_value_attributes)
          put spree.api_option_value_path(option_value), params: {option_value: {name: ""}}
        end

        it "cannot update an option value with invalid attributes" do
          put spree.api_option_value_path(option_value), params: {option_value: {
            name: ""
          }}
          expect(response.status).to eq(422)
        end

        it "can delete an option value" do
          delete spree.api_option_value_path(option_value)
          expect(response.status).to eq(204)
        end
      end
    end
  end
end
