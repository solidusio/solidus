# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Quick switch", type: :request do
  stub_authorization!

  let!(:order) { FactoryBot.create :order, number: "R1234" }
  let!(:product) { FactoryBot.create :product, sku: "SKU123" }
  let!(:shipment) { FactoryBot.create :shipment, number: "S1234" }
  let!(:user) { FactoryBot.create :user, email: "jessicajones@example.com" }
  let!(:variant) { FactoryBot.create :variant, sku: "SKU456" }

  context "with valid parameters" do
    it "returns an order's edit URL when we query orders" do
      get spree.admin_quick_switch_path, params: { quick_switch_query: "o R1234" }

      expect(response.status).to eq 200
      expect(json_response["redirect_url"]).to eq(
        spree.edit_admin_order_path(order)
      )
    end

    it "returns an order's edit URL when we query shipments" do
      get spree.admin_quick_switch_path, params: { quick_switch_query: "s S1234" }

      expect(response.status).to eq 200
      expect(json_response["redirect_url"]).to eq(
        spree.edit_admin_order_path(shipment.order)
      )
    end

    it "returns a user's edit URL when we query users" do
      get spree.admin_quick_switch_path, params: { quick_switch_query: "u jessicajones@example.com" }

      expect(response.status).to eq 200
      expect(json_response["redirect_url"]).to eq(
        spree.edit_admin_user_path(user)
      )
    end

    it "returns a variant's edit URL when we query variants" do
      get spree.admin_quick_switch_path, params: { quick_switch_query: "v SKU456" }

      expect(response.status).to eq 200
      expect(json_response["redirect_url"]).to eq(
        spree.edit_admin_product_variant_path(
          variant.product,
          variant
        )
      )
    end

    it "returns a product's edit URL when our query is a master variant" do
      get spree.admin_quick_switch_path, params: { quick_switch_query: "p SKU123" }

      expect(response.status).to eq 200
      expect(json_response["redirect_url"]).to eq(
        spree.edit_admin_product_path(product)
      )
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
