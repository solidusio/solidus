# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe 'Stores', type: :request do
    let(:country) { create :country, states_required: true }
    let(:country_without_states) { create :country, states_required: false }
    let(:state) { create :state, name: 'maryland', abbr: 'md', country: }
    let!(:base_attributes) { Spree::Api::Config.store_attributes }

    let!(:store) do
      create(:store, name: "My Spree Store", url: "spreestore.example.com")
    end

    before do
      stub_authentication!
    end

    context "as an admin" do
      sign_in_as_admin!

      let!(:non_default_store) do
        create(:store,
          name: "Extra Store",
          url: "spreestore-5.example.com",
          default: false)
      end

      describe "store state validation" do
        context "when store country has states_required" do
          it "is invalid without a state" do
            store = Spree::Store.new(name: "Test Store", country: country, state: nil, url: "spreestore.example.com",
              mail_from_address: "spreestore@example.com", code: "test-store",)
            expect(store).not_to be_valid
            expect(store.errors[:state]).to include("can't be blank")
          end

          it "is valid with a state" do
            store = Spree::Store.new(name: "Test Store", country: country, state: state, url: "spreestore.example.com",
              mail_from_address: "spreestore@example.com", code: "test-store",)
            expect(store).to be_valid
          end
        end

        context "when store country has no states" do
          it "is valid without a state" do
            store = Spree::Store.new(name: "Test Store", country: country_without_states, state: nil, url: "spreestore.example.com",
              mail_from_address: "spreestore@example.com", code: "test-store",)
            expect(store).to be_valid
          end
        end

        it "is valid without an address and without country/state" do
          expect(store).to be_valid
        end

        it "is valid with only correct country and state" do
          store = Spree::Store.create!(
            name: "Test Store",
            url: "spreestore.example.com",
            mail_from_address: "spreestore.example.com",
            code: "test-store",
            address1: "123 Main St",
            city: "New York",
            zipcode: "10001",
            state: state,
            country: country,
          )
          expect(store).to be_valid
        end
      end

      describe "#index" do
        it "ensures the API store attributes match the expected attributes" do
          get spree.api_stores_path
          first_store = json_response["stores"].first
          expect(first_store.keys).to include(*base_attributes.map(&:to_s))
        end
      end

      it "can list the available stores" do
        get spree.api_stores_path
        expect(json_response["stores"]).to match_array([
          {
            "id" => store.id,
            "name" => "My Spree Store",
            "url" => "spreestore.example.com",
            "meta_description" => nil,
            "meta_keywords" => nil,
            "seo_title" => nil,
            "mail_from_address" => "solidus@example.org",
            "bcc_email" => nil,
            "default_currency" => nil,
            "code" => store.code,
            "default" => true,
            "available_locales" => ["en"],
            "legal_name" => nil,
            "contact_email" => nil,
            "contact_phone" => nil,
            "description" => nil,
            "tax_id" => nil,
            "vat_id" => nil,
            "address1" => nil,
            "address2" => nil,
            "city" => nil,
            "zipcode" => nil,
            "country_id" => nil,
            "state_id" => nil,
            "state_name" => nil
          },
          {
            "id" => non_default_store.id,
            "name" => "Extra Store",
            "url" => "spreestore-5.example.com",
            "meta_description" => nil,
            "meta_keywords" => nil,
            "seo_title" => nil,
            "mail_from_address" => "solidus@example.org",
            "bcc_email" => nil,
            "default_currency" => nil,
            "code" => non_default_store.code,
            "default" => false,
            "available_locales" => ["en"],
            "legal_name" => nil,
            "contact_email" => nil,
            "contact_phone" => nil,
            "description" => nil,
            "tax_id" => nil,
            "vat_id" => nil,
            "address1" => nil,
            "address2" => nil,
            "city" => nil,
            "zipcode" => nil,
            "country_id" => nil,
            "state_id" => nil,
            "state_name" => nil
          }
        ])
      end

      it "can get the store details" do
        get spree.api_store_path(store)
        expect(json_response).to eq(
          "id" => store.id,
          "name" => "My Spree Store",
          "url" => "spreestore.example.com",
          "meta_description" => nil,
          "meta_keywords" => nil,
          "seo_title" => nil,
          "mail_from_address" => "solidus@example.org",
          "bcc_email" => nil,
          "default_currency" => nil,
          "code" => store.code,
          "default" => true,
          "available_locales" => ["en"],
          "legal_name" => nil,
          "contact_email" => nil,
          "contact_phone" => nil,
          "description" => nil,
          "tax_id" => nil,
          "vat_id" => nil,
          "address1" => nil,
          "address2" => nil,
          "city" => nil,
          "zipcode" => nil,
          "country_id" => nil,
          "state_id" => nil,
          "state_name" => nil
        )
      end

      it "can create a new store" do
        store_hash = {
          code: "spree123",
          name: "Hack0rz",
          url: "spree123.example.com",
          mail_from_address: "me@example.com",
          legal_name: 'ABC Corp',
          address1: "123 Main St",
          city: 'San Francisco',
          country_id: country.id,
          state_id: state.id,
          phone: "123-456-7890",
          zipcode: "12345"
        }
        post spree.api_stores_path, params: { store: store_hash }
        expect(response.status).to eq(201)
      end

      it "can update an existing store" do
        store_hash = {
          url: "spree123.example.com",
          mail_from_address: "me@example.com",
          bcc_email: "bcc@example.net",
          legal_name: 'XYZ Corp',
          description: "Leading provider of high-quality tech accessories, offering the latest gadgets, peripherals, and electronics to enhance your digital lifestyle.",
          tax_id: "TX-987654321",
          vat_id: "VAT-123456789",
          address1: "123 Innovation Drive",
          address2: "Suite 456",
          city: "New York",
          country_id: country.id,
          state_id: state.id,
          contact_phone: "123-456-7888",
          zipcode: "10001"
        }
        put spree.api_store_path(store), params: { store: store_hash }
        expect(response.status).to eq(200)
        expect(store.reload.url).to eql "spree123.example.com"
        expect(store.reload.mail_from_address).to eql "me@example.com"
        expect(store.reload.bcc_email).to eql "bcc@example.net"
        expect(store.reload.legal_name).to eql "XYZ Corp"
        expect(store.reload.tax_id).to eql "TX-987654321"
        expect(store.reload.vat_id).to eql "VAT-123456789"
        expect(store.reload.address1).to eql "123 Innovation Drive"
        expect(store.reload.address2).to eql "Suite 456"
        expect(store.reload.city).to eql "New York"
        expect(store.reload.country_id).to eql country.id
        expect(store.reload.state_id).to eql state.id
        expect(store.reload.contact_phone).to eql "123-456-7888"
        expect(store.reload.zipcode).to eql "10001"
      end

      context "deleting a store" do
        it "will fail if it's the default Store" do
          delete spree.api_store_path(store)
          expect(response.status).to eq(422)
          expect(json_response["errors"]["base"]).to eql(
            ["Cannot destroy the default Store."]
          )
        end

        it "will destroy the store" do
          delete spree.api_store_path(non_default_store)
          expect(response.status).to eq(204)
        end
      end
    end

    context "as an user" do
      it "cannot list all the stores" do
        get spree.api_stores_path
        expect(response.status).to eq(401)
      end

      it "cannot get the store details" do
        get spree.api_store_path(store)
        expect(response.status).to eq(401)
      end

      it "cannot create a new store" do
        post spree.api_stores_path, params: { store: {} }
        expect(response.status).to eq(401)
      end

      it "cannot update an existing store" do
        put spree.api_store_path(store), params: { store: {} }
        expect(response.status).to eq(401)
      end
    end
  end
end
