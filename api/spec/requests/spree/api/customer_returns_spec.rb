# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::CustomerReturnsController, type: :request do
    let!(:order) { create(:shipped_order) }
    let(:attributes) { [:id, :number, :stock_location_id] }

    before do
      stub_authentication!
    end

    context "as a non admin" do
      before do
        allow_any_instance_of(Order).to receive_messages user: create(:user)
      end

      it "cannot see any customer returns" do
        get spree.api_order_customer_returns_path(order)

        assert_unauthorized!
      end

      it "cannot see a single customer return" do
        get spree.api_order_customer_return_path(order, 1)

        assert_unauthorized!
      end

      it "cannot learn how to create a new customer return" do
        get spree.new_api_order_customer_return_path(order)

        assert_unauthorized!
      end

      it "cannot update a customer return" do
        put spree.api_order_customer_return_path(order, 0)

        assert_unauthorized!
      end

      it "cannot create a new customer return" do
        post spree.api_order_customer_returns_path(order)

        assert_unauthorized!
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can show customer return" do
        customer_return = FactoryBot.create(:customer_return)

        get spree.api_order_customer_return_path(customer_return.order, customer_return.id)

        expect(response.status).to eq(200)
        expect(json_response).to have_attributes(attributes)
      end

      it "can get a list of customer returns" do
        FactoryBot.create(:customer_return, shipped_order: order)
        FactoryBot.create(:customer_return, shipped_order: order)

        get spree.api_order_customer_returns_path(order), params: { order_id: order.number }

        expect(response.status).to eq(200)

        customer_returns = json_response["customer_returns"]

        expect(customer_returns.first).to have_attributes(attributes)
        expect(customer_returns.first).not_to eq(customer_returns.last)
      end

      it 'can control the page size through a parameter' do
        FactoryBot.create(:customer_return, shipped_order: order)
        FactoryBot.create(:customer_return, shipped_order: order)

        get spree.api_order_customer_returns_path(order), params: { order_id: order.number, per_page: 1 }

        expect(json_response['count']).to eq(1)
        expect(json_response['current_page']).to eq(1)
        expect(json_response['pages']).to eq(2)
      end

      it 'can query the results through a parameter' do
        FactoryBot.create(:customer_return, shipped_order: order)
        expected_result = FactoryBot.create(:customer_return, number: 'CR12', shipped_order: order)

        get spree.api_order_customer_returns_path(order), params: { q: { number_eq: 'CR12' } }

        expect(json_response['count']).to eq(1)
        expect(json_response["customer_returns"].first['number']).to eq expected_result.number
      end

      it "can learn how to create a new customer return" do
        get spree.new_api_order_customer_return_path(order)

        expect(json_response["attributes"]).to eq(["id", "number", "stock_location_id", "created_at", "updated_at"])
      end

      it "can update a customer return" do
        initial_stock_location = FactoryBot.create(:stock_location)
        final_stock_location = FactoryBot.create(:stock_location)
        customer_return = FactoryBot.create(:customer_return, stock_location: initial_stock_location)

        put spree.api_order_customer_return_path(customer_return.order, customer_return.id), params: { order_id: customer_return.order.number, customer_return: { stock_location_id: final_stock_location.id } }

        expect(response.status).to eq(200)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["stock_location_id"]).to eq final_stock_location.id
      end

      it "can create a new customer return" do
        stock_location = FactoryBot.create(:stock_location)
        unit = FactoryBot.create(:inventory_unit, state: "shipped")
        cr_params = { stock_location_id: stock_location.id,
                       return_items_attributes: [{
                         inventory_unit_id: unit.id,
                         reception_status_event: "receive",
                       }] }

        post spree.api_order_customer_returns_path(order), params: { order_id: order.number, customer_return: cr_params }

        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)

        customer_return = Spree::CustomerReturn.last

        expect(customer_return.return_items.first.reception_status).to eql "received"
      end
    end
  end
end
