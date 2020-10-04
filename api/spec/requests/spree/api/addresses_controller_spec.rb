# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::AddressesController, type: :request do
    before do
      stub_authentication!
      @address = create(:address)
      @order = create(:order, bill_address: @address)
    end

    context "with order" do
      before do
        allow_any_instance_of(Order).to receive_messages user: current_api_user
      end

      context "with their own address" do
        it "gets an address" do
          get spree.api_order_address_path(@order, @address.id)
          expect(json_response['address1']).to eq @address.address1
        end

        it "update replaces the readonly Address associated to the Order" do
          put spree.api_order_address_path(@order, @address.id), params: { address: { address1: "123 Test Lane" } }
          expect(Order.find(@order.id).bill_address_id).not_to eq @address.id
          expect(json_response['address1']).to eq '123 Test Lane'
        end

        it "receives the errors object if address is invalid" do
          put spree.api_order_address_path(@order, @address.id), params: { address: { address1: "" } }

          expect(json_response['error']).not_to be_nil
          expect(json_response['errors']).not_to be_nil
          expect(json_response['errors']['address1'].first).to eq "can't be blank"
        end
      end
    end

    context "on an address that does not belong to this order" do
      before do
        @order.bill_address_id = nil
        @order.ship_address = nil
      end

      it "cannot retrieve address information" do
        get spree.api_order_address_path(@order, @address.id)
        assert_unauthorized!
      end

      it "cannot update address information" do
        get spree.api_order_address_path(@order, @address.id)
        assert_unauthorized!
      end
    end
  end
end
