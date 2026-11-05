# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe "Addresses during checkout", type: :request do
    let(:country) { create(:country) }
    let(:new_york) { create(:state, country:, name: "New York", abbr: "NY", state_code: "NY") }
    let(:california) { create(:state, country:, name: "California", abbr: "CA", state_code: "CA") }
    let(:ny_zone) { create(:zone, name: "NY").tap { |zone| zone.members.create!(zoneable: new_york) } }
    let(:ca_zone) { create(:zone, name: "CA").tap { |zone| zone.members.create!(zoneable: california) } }
    let!(:ny_shipping) { create(:shipping_method, name: "NY ground", cost: 1, zones: [ny_zone]) }
    let!(:ca_shipping) { create(:shipping_method, name: "CA ground", cost: 10, zones: [ca_zone]) }
    let!(:payment_method) { create(:check_payment_method) }

    let(:ny_address) { create(:address, state: new_york, country:) }
    let(:order) do
      create(:order_with_line_items, ship_address: ny_address, bill_address: create(:address, state: new_york, country:, address1: "1 Billing St"), user: nil, email: "guest@example.com")
    end
    let(:token_params) { {order_token: order.guest_token} }

    before do
      order.next! until order.state == "delivery"
    end

    it "restarts the checkout when the ship address changes" do
      expect(order.shipments.first.shipping_method).to eq(ny_shipping)

      put spree.api_order_address_path(order, order.ship_address_id),
        params: token_params.merge(address: {state_id: california.id, city: "Los Angeles", zipcode: "90001"})

      expect(response.status).to eq(200)
      order.reload
      expect(order.ship_address.state).to eq(california)
      expect(order.state).to eq("address")
      expect(order.shipments).to be_empty
      expect(order.shipment_total).to eq(0)

      order.next!
      expect(order.shipments.map(&:shipping_method)).to eq([ca_shipping])
      expect(order.shipment_total).to eq(10)
    end
  end
end
