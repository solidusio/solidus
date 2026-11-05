# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe "API fragment caching", type: :request, caching: true do
    let(:admin) { create(:admin_user, :with_api_key) }
    let(:customer) { create(:user, :with_api_key) }

    def get_as(user, path)
      get path, headers: { "Authorization" => "Bearer #{user.spree_api_key}" }
      expect(response).to have_http_status(:ok)
      json_response
    end

    describe "GET /api/variants/:id" do
      let(:variant) { create(:variant, cost_price: 7) }

      it "does not serve admin-only attributes to a customer after an admin request" do
        expect(get_as(admin, spree.api_variant_path(variant))).to have_key("cost_price")
        expect(get_as(customer, spree.api_variant_path(variant))).not_to have_key("cost_price")
      end

      it "serves admin-only attributes to an admin after a customer request" do
        expect(get_as(customer, spree.api_variant_path(variant))).not_to have_key("cost_price")
        expect(get_as(admin, spree.api_variant_path(variant))).to have_key("cost_price")
      end
    end

    describe "GET /api/orders/:number" do
      let(:order) { create(:order_with_line_items) }

      it "does not serve admin-only attributes to a guest after an admin request" do
        as_admin = get_as(admin, spree.api_order_path(order))
        expect(as_admin).to have_key("admin_metadata")
        expect(as_admin["line_items"].first).to have_key("admin_metadata")
        expect(as_admin["line_items"].first["variant"]).to have_key("cost_price")
        expect(as_admin["shipments"].first).to have_key("admin_metadata")

        get spree.api_order_path(order), params: { order_token: order.guest_token }
        expect(response).to have_http_status(:ok)

        expect(json_response).not_to have_key("admin_metadata")
        expect(json_response["line_items"].first).not_to have_key("admin_metadata")
        expect(json_response["line_items"].first["variant"]).not_to have_key("cost_price")
        expect(json_response["shipments"].first).not_to have_key("admin_metadata")
      end
    end

    describe "GET /api/shipments/mine" do
      let(:order) { create(:order_with_line_items, user: customer) }

      it "does not serve admin-only attributes to a customer after an admin request" do
        shipment = order.shipments.first
        put spree.api_shipment_path(shipment), headers: { "Authorization" => "Bearer #{admin.spree_api_key}" }
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("admin_metadata")
        get_as(admin, spree.api_order_path(order))

        shipment_json = get_as(customer, spree.mine_api_shipments_path)["shipments"].first

        expect(shipment_json).not_to have_key("admin_metadata")
        expect(shipment_json["order"]).not_to have_key("admin_metadata")
        expect(shipment_json["inventory_units"].first["variant"]).not_to have_key("cost_price")
      end
    end
  end
end
