# frozen_string_literal: true

require "solidus_storefront_spec_helper"

RSpec.describe "Paypal Orders", type: :request do
  stub_authorization!

  before do
    create :store
  end

  describe "POST /solidus_paypal_commerce_platform/orders" do
    subject { post "/solidus_paypal_commerce_platform/orders", params: params }

    let(:variant) { create(:variant) }
    let(:params) {
      {
        order: {
          line_items_attributes: [
            {
              variant_id: variant.id,
              quantity: 1
            }
          ]
        }
      }
    }

    it "creates a new order" do
      expect {
        subject
      }.to change(Spree::Order, :count).by(1)
    end

    it "updates the order with the provided line items" do
      subject

      expect(JSON.parse(response.body)).to include(
        "item_count" => 1,
        "item_total" => variant.price.to_s
      )
    end

    context "when the order is invalid" do
      let(:params) {
        {
          order: {
            line_items_attributes: [
              {
                variant_id: "not a real id",
                quantity: 1
              }
            ]
          }
        }
      }

      it "returns an error" do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          "Line items variant can't be blank",
          "Line items price is not valid"
        )
      end
    end
  end

  describe "POST /update_address" do
    subject { post "/solidus_paypal_commerce_platform/update_address", params: params }

    let(:order) { create(:order_with_line_items) }
    let(:params) {
      {
        order_id: order.number,
        order_token: order.guest_token,
        address: {
          updated_address: {
            address_line_1: "123 Main St",
            admin_area_1: state_abbr,
            admin_area_2: "Los Angeles",
            postal_code: "90001",
            country_code: "US"
          },
          recipient: {
            email_address: "test@example.com",
            name: {
              given_name: "Monty",
              surname: "Norman"
            }
          }
        }
      }
    }
    let(:state_abbr) { california.abbr }
    let(:california) { create :state, name: "California", abbr: "CA" }

    it "updates the order's shipping address" do
      expect { subject }
        .to change { order.reload.ship_address&.attributes }
        .to include(
          "address1" => "123 Main St",
          "state_id" => california.id,
          "city" => "Los Angeles",
          "zipcode" => "90001",
          "name" => "Monty Norman"
        )
    end

    context "when the address is invalid" do
      let(:state_abbr) { "ZZ" }

      it "returns an error" do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          "State can't be blank"
        )
      end
    end
  end

  describe "GET /solidus_paypal_commerce_platform/verify_total" do
    subject { get "/solidus_paypal_commerce_platform/verify_total", params: params }

    let(:order) { create(:order_with_line_items) }

    context "when the amount is correct" do
      let(:params) {
        {
          order_id: order.number,
          paypal_total: order.total,
          format: :json
        }
      }

      it "succeeds" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the amount is incorrect" do
      let(:params) {
        {
          order_id: order.number,
          paypal_total: order.total - 1,
          format: :json
        }
      }

      it "returns a 400 error" do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
