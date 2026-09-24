# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::StoresController", type: :request do
  before { create(:store, default: true) } # create a default store so that we operate on a non-default one

  include_examples "CRUD resource requests", "store" do
    let(:resource_class) { Spree::Store }
    let(:valid_attributes) { {name: "Store", code: "store", url: "store.com", mail_from_address: "store@example.com"} }
    let(:invalid_attributes) { {name: ""} }
  end

  describe "address" do
    let(:admin_user) { create(:admin_user) }
    let(:store) { create(:store, default: false) }
    let(:country) { create(:country, states_required: false) }
    let(:address_attributes) do
      {name: "Store Inc.", address1: "1 Store Street", city: "Storetown", zipcode: "12345", phone: "555-555-0199", vat_id: "DE123456789", country_id: country.id}
    end

    before { allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user) }

    it "renders the address fields without email, address2 and VAT-ID" do
      get solidus_admin.edit_store_path(store)
      expect(response.body).to include('name="store[address_attributes][address1]"')
      expect(response.body).to include('name="store[address_attributes][phone]"')
      expect(response.body).not_to include('name="store[address_attributes][email]"')
      expect(response.body).not_to include('name="store[address_attributes][address2]"')
      expect(response.body).not_to include('name="store[address_attributes][vat_id]"')
    end

    it "does not render the phone field if phone is not required" do
      allow(Spree::Config).to receive(:address_requires_phone).and_return(false)
      get solidus_admin.edit_store_path(store)
      expect(response.body).not_to include('name="store[address_attributes][phone]"')
    end

    it "renders the VAT-ID once if reverse charge fields are shown" do
      allow(Spree::Backend::Config).to receive(:show_reverse_charge_fields).and_return(true)
      get solidus_admin.edit_store_path(store)
      expect(response.body.scan('name="store[address_attributes][vat_id]"').size).to eq(1)
    end

    it "saves the address" do
      patch solidus_admin.store_path(store), params: {store: {address_attributes:}}
      expect(store.reload.address).to have_attributes(address_attributes)
    end

    it "does not create an address from blank fields" do
      patch solidus_admin.store_path(store), params: {store: {address_attributes: {name: "", address1: "", country_id: country.id, reverse_charge_status: "disabled"}}}
      expect(response).to have_http_status(:see_other)
      expect(store.reload.address).to be_nil
    end

    it "creates a store without address from blank fields" do
      post solidus_admin.stores_path, params: {store: {name: "New Store", code: "new-store", url: "new-store.com", mail_from_address: "store@example.com", address_attributes: {name: "", address1: "", country_id: country.id}}}
      expect(response).to have_http_status(:see_other)
      expect(Spree::Store.find_by!(code: "new-store").address).to be_nil
    end
  end
end
