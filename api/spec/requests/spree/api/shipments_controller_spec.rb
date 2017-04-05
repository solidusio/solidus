require 'spec_helper'

RSpec.describe Spree::Api::ShipmentsController, type: :request do
  let(:user) { create(:admin_user, spree_api_key: 'abc123') }
  let(:stock_item) { create(:stock_item, backorderable: false) }
  let(:variant) { stock_item.variant }

  let(:order) do
    create(
      :completed_order_with_totals,
      user: user,
      line_items_attributes: [
        {
          variant: variant
        }
      ]
    )
  end

  let(:shipment) { order.shipments.first }

  describe "POST /api/shipments/transfer_to_location" do
    let(:stock_location) { create(:stock_location) }
    let(:source_shipment) { order.shipments.first }
    let(:parsed_response) { JSON.parse(response.body) }
    let(:stock_location_id) { stock_location.id }

    subject do
      post "/api/shipments/transfer_to_location.json",
        params: {
          original_shipment_number: source_shipment.number,
          stock_location_id: stock_location_id,
          quantity: 1,
          variant_id: variant.id,
          token: user.spree_api_key
        }
    end

    context "for a successful transfer" do
      before do
        stock_location.restock(variant, 1)
      end

      it "returns the correct message" do
        subject
        expect(response).to be_success
        expect(parsed_response["success"]).to be true
        expect(parsed_response["message"]).to eq("Variants successfully transferred")
      end
    end

    context "if the source shipment can not be found" do
      let(:stock_location_id) { 9999 }

      it "returns a 404" do
        subject
        expect(response).to be_not_found
        expect(parsed_response["error"]).to eq("The resource you were looking for could not be found.")
      end
    end

    context "if the user can not update shipments" do
      let(:user) { create(:user, spree_api_key: 'abc123') }

      custom_authorization! do |_|
        can :read, Spree::Shipment
        cannot :update, Spree::Shipment
        can :create, Spree::Shipment
        can :destroy, Spree::Shipment
      end

      it "is not authorized" do
        subject
        expect(response).to be_unauthorized
      end
    end

    context "if the user can not destroy shipments" do
      let(:user) { create(:user, spree_api_key: 'abc123') }

      custom_authorization! do |_|
        can :read, Spree::Shipment
        can :update, Spree::Shipment
        cannot :destroy, Spree::Shipment
        can :create, Spree::Shipment
      end

      it "is not authorized" do
        subject
        expect(response).to be_unauthorized
      end
    end
  end

  describe "POST /api/shipments/transfer_to_shipment" do
    let(:stock_location) { create(:stock_location) }
    let(:source_shipment) { order.shipments.first }
    let(:target_shipment) { order.shipments.create(stock_location: stock_location) }
    let(:parsed_response) { JSON.parse(response.body) }
    let(:source_shipment_number) { source_shipment.number }

    subject do
      post "/api/shipments/transfer_to_shipment.json",
        params: {
          original_shipment_number: source_shipment_number,
          target_shipment_number: target_shipment.number,
          quantity: 1,
          variant_id: variant.id,
          token: user.spree_api_key
        }
    end

    context "for a successful transfer" do
      before do
        stock_location.restock(variant, 1)
      end

      it "returns the correct message" do
        subject
        expect(response).to be_success
        expect(parsed_response["success"]).to be true
        expect(parsed_response["message"]).to eq("Variants successfully transferred")
      end
    end

    context "if the source shipment can not be found" do
      let(:source_shipment_number) { 9999 }

      it "returns a 404" do
        subject
        expect(response).to be_not_found
        expect(parsed_response["error"]).to eq("The resource you were looking for could not be found.")
      end
    end
  end
end
