# frozen_string_literal: true

require "spec_helper"

describe Spree::Admin::StoresController, type: :controller do
  stub_authorization!

  let(:store) { create(:store) }
  let(:country) { create(:country, states_required: false) }
  let(:address_attributes) do
    {name: "Store Inc.", address1: "1 Store Street", city: "Storetown", zipcode: "12345", phone: "555-555-0199", country_id: country.id}
  end

  describe "#edit" do
    render_views

    it "renders the address fields without email and address2" do
      get :edit, params: {id: store.id}
      expect(response.body).to include('name="store[address_attributes][address1]"')
      expect(response.body).to include('name="store[address_attributes][phone]"')
      expect(response.body).not_to include('name="store[address_attributes][email]"')
      expect(response.body).not_to include('name="store[address_attributes][address2]"')
    end

    it "does not render the phone field if phone is not required" do
      stub_spree_preferences(address_requires_phone: false)
      get :edit, params: {id: store.id}
      expect(response.body).not_to include('name="store[address_attributes][phone]"')
    end
  end

  describe "#update" do
    it "saves the address" do
      put :update, params: {id: store.id, store: {address_attributes:}}
      expect(store.reload.address).to have_attributes(address_attributes)
    end

    it "does not create an address from blank fields" do
      put :update, params: {id: store.id, store: {name: "New Name", address_attributes: {name: "", address1: "", country_id: country.id, reverse_charge_status: "disabled"}}}
      expect(store.reload).to have_attributes(name: "New Name", address: nil)
    end
  end

  describe "#create" do
    it "creates a store without address from blank fields" do
      post :create, params: {store: {name: "New Store", code: "new-store", url: "new-store.com", mail_from_address: "store@example.com", address_attributes: {name: "", address1: "", country_id: country.id}}}
      expect(Spree::Store.find_by!(code: "new-store").address).to be_nil
    end
  end
end
