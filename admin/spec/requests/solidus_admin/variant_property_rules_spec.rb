# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::VariantPropertyRulesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:color) { create(:option_type, name: "clothing-color", presentation: "Color") }
  let!(:red) { create(:option_value, option_type: color, name: "red", presentation: "Red") }
  let(:product) { create(:product, option_types: [color]) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /new" do
    it "renders the specifications dialog" do
      get solidus_admin.new_product_variant_property_rule_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Add specifications")
      expect(response.body).to include("Color: Red")
    end

    context "when the user cannot manage products" do
      let(:admin_user) { create(:limited_admin_user, permissions: [Spree::PermissionSets::ProductDisplay]) }

      it "responds as forbidden" do
        get solidus_admin.new_product_variant_property_rule_path(product)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /create" do
    let(:params) do
      {
        variant_property_rule: {
          option_value_ids: ["", red.id],
          apply_to_all: "1",
          values_attributes: {"0" => {property_name: "care", value: "Dry clean only"}}
        }
      }
    end

    it "creates the rule and responds with a turbo stream" do
      expect {
        post solidus_admin.product_variant_property_rules_path(product, format: :turbo_stream), params: params
      }.to change { product.variant_property_rules.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="specifications_panel"')

      rule = product.variant_property_rules.last
      expect(rule.option_values).to eq([red])
      expect(rule.apply_to_all).to be(true)
      expect(rule.values.map { |value| [value.property_name, value.value] }).to eq([["care", "Dry clean only"]])
    end

    it "redirects to the product when not requested as a turbo stream" do
      post solidus_admin.product_variant_property_rules_path(product), params: params

      expect(response).to redirect_to(solidus_admin.product_path(product))
      expect(response).to have_http_status(:see_other)
    end

    context "with no option values" do
      let(:params) do
        {
          variant_property_rule: {
            option_value_ids: [""],
            apply_to_all: "0",
            values_attributes: {"0" => {property_name: "care", value: "Dry clean only"}}
          }
        }
      end

      it "re-renders the dialog with a 422 status" do
        expect {
          post solidus_admin.product_variant_property_rules_path(product, format: :turbo_stream), params: params
        }.not_to change { Spree::VariantPropertyRule.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Add specifications")
        expect(response.body).to include("can&#39;t be blank")
      end
    end
  end

  describe "GET /edit" do
    let(:rule) { create(:variant_property_rule, product:, option_value: red) }

    it "renders the specifications dialog" do
      get solidus_admin.edit_product_variant_property_rule_path(product, rule)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit specifications")
    end
  end

  describe "PATCH /update" do
    let(:blue) { create(:option_value, option_type: color, name: "blue", presentation: "Blue") }
    let(:rule) { create(:variant_property_rule, product:, option_value: red, property_value: "Max 30°") }
    let(:params) do
      {
        variant_property_rule: {
          option_value_ids: ["", blue.id],
          apply_to_all: "0",
          values_attributes: {
            "0" => {id: rule.values.first.id, property_name: rule.values.first.property_name, value: "Max 40°"}
          }
        }
      }
    end

    it "updates the rule and responds with a turbo stream" do
      patch solidus_admin.product_variant_property_rule_path(product, rule, format: :turbo_stream), params: params

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="specifications_panel"')

      rule.reload
      expect(rule.option_values).to eq([blue])
      expect(rule.apply_to_all).to be(false)
      expect(rule.values.map(&:value)).to eq(["Max 40°"])
    end

    context "with explicit positions" do
      let(:washing) { create(:property, name: "washing") }
      let!(:care_value) { rule.values.create!(property: washing, value: "Dry clean only") }
      let(:params) do
        {
          variant_property_rule: {
            option_value_ids: ["", red.id],
            values_attributes: {
              "0" => {id: rule.values.first.id, property_name: rule.values.first.property_name, position: 2},
              "1" => {id: care_value.id, property_name: "washing", position: 1}
            }
          }
        }
      end

      it "persists the positions as sent" do
        patch solidus_admin.product_variant_property_rule_path(product, rule, format: :turbo_stream), params: params

        expect(response).to have_http_status(:ok)
        expect(rule.values.reload.map { |value| [value.value, value.position] }).to eq([["Dry clean only", 1], ["Max 30°", 2]])
      end
    end

    context "with no option values" do
      let(:params) { {variant_property_rule: {option_value_ids: [""]}} }

      it "re-renders the dialog with a 422 status and keeps the rule" do
        patch solidus_admin.product_variant_property_rule_path(product, rule, format: :turbo_stream), params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Edit specifications")
        expect(rule.reload.option_values).to eq([red])
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:rule) { create(:variant_property_rule, product:, option_value: red) }

    it "destroys the rule and responds with a turbo stream" do
      expect {
        delete solidus_admin.product_variant_property_rule_path(product, rule, format: :turbo_stream)
      }.to change { product.variant_property_rules.count }.by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('target="specifications_panel"')
    end

    it "redirects to the product when not requested as a turbo stream" do
      delete solidus_admin.product_variant_property_rule_path(product, rule)

      expect(response).to redirect_to(solidus_admin.product_path(product))
      expect(response).to have_http_status(:see_other)
    end
  end
end
