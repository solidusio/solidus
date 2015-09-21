require 'spec_helper'

module Spree
  describe Api::AddressBooksController, :type => :controller do
    render_views

    context "unauthorized user" do
      it "get 401 on /show" do
        api_get :show
        expect(response.status).to eq 401
      end

      it "get 401 on /update" do
        api_put :update
        expect(response.status).to eq 401
      end

      it "get 401 on /destroy" do
        api_delete :destroy, address_id: 1
        expect(response.status).to eq 401
      end
    end

    context "authorized user with addresses" do
      let(:address1) { create(:address) }
      let(:address2) { create(:address, firstname: "Different") }

      before do
        stub_authentication!
        current_api_user.save_in_address_book(address1.attributes, true)
        current_api_user.save_in_address_book(address2.attributes, false)
      end

      it "gets their address book" do
        api_get :show
        expect(json_response.length).to eq 2
      end

      it "the first one is default" do
        api_get :show
        first, second = *json_response
        expect(first["default"]).to be true
        expect(second["default"]).to be false
      end

      it "can remove an address" do
        api_delete :destroy, address_id: address1.id
        expect(json_response.length).to eq 1
      end

      it "can update an address" do
        updated_params = address2.attributes
        updated_params[:firstname] = "Johnny"
        updated_params[:default] = true
        api_put :update, address_book: updated_params
        expect(json_response.first["firstname"]).to eq "Johnny"
      end
    end
  end
end
