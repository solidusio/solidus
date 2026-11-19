# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::VariantPropertyRuleValuesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:color) { create(:option_type, name: "clothing-color", presentation: "Color") }
  let(:red) { create(:option_value, option_type: color, name: "red", presentation: "Red") }
  let(:product) { create(:product, option_types: [color]) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /new" do
    it "appends a blank row to the dialog of a new rule" do
      get solidus_admin.new_product_variant_property_rule_value_path(product, format: :turbo_stream)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="append" target="specification_rows"')
      expect(response.body).to match(/name="variant_property_rule\[values_attributes\]\[\d+\]\[property_name\]"/)
      expect(response.body).to match(/name="variant_property_rule\[values_attributes\]\[\d+\]\[value\]"/)
      expect(response.body).to match(/name="variant_property_rule\[values_attributes\]\[\d+\]\[_destroy\]"/)
      expect(response.body).to match(/name="variant_property_rule\[values_attributes\]\[\d+\]\[position\]" value="1"/)
    end

    context "with a persisted rule" do
      let(:rule) { create(:variant_property_rule, product:, option_value: red) }

      before { rule.values.first.update!(position: 2) }

      it "appends a blank row after the last persisted one" do
        get solidus_admin.new_product_variant_property_rule_value_path(product, variant_property_rule_id: rule.id, format: :turbo_stream)

        expect(response).to have_http_status(:ok)
        expect(response.body).to match(/name="variant_property_rule\[values_attributes\]\[\d+\]\[property_name\]"/)
        expect(response.body).to match(/name="variant_property_rule\[values_attributes\]\[\d+\]\[position\]" value="3"/)
      end
    end

    context "when the user cannot manage products" do
      let(:admin_user) { create(:limited_admin_user, permissions: [Spree::PermissionSets::ProductDisplay]) }

      it "responds as forbidden" do
        get solidus_admin.new_product_variant_property_rule_value_path(product)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
