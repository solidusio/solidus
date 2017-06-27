require "spec_helper"

module Spree
  describe Api::StoresController, type: :request do

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
          default: false
        )
      end

      it "I can list the available stores" do
        get :index
        expect(json_response["stores"]).to match_array([
          {
            "id" => store.id,
            "name" => "My Spree Store",
            "url" => "spreestore.example.com",
            "meta_description" => nil,
            "meta_keywords" => nil,
            "seo_title" => nil,
            "mail_from_address" => "spree@example.org",
            "default_currency" => nil,
            "code" => store.code,
            "default" => true
          },
          {
            "id" => non_default_store.id,
            "name" => "Extra Store",
            "url" => "spreestore-5.example.com",
            "meta_description" => nil,
            "meta_keywords" => nil,
            "seo_title" => nil,
            "mail_from_address" => "spree@example.org",
            "default_currency" => nil,
            "code" => non_default_store.code,
            "default" => false
          }
        ])
      end

      it "I can get the store details" do
        get :show, params: { id: store.id }
        expect(json_response).to eq(
          "id" => store.id,
          "name" => "My Spree Store",
          "url" => "spreestore.example.com",
          "meta_description" => nil,
          "meta_keywords" => nil,
          "seo_title" => nil,
          "mail_from_address" => "spree@example.org",
          "default_currency" => nil,
          "code" => store.code,
          "default" => true
        )
      end

      it "I can create a new store" do
        store_hash = {
          code: "spree123",
          name: "Hack0rz",
          url: "spree123.example.com",
          mail_from_address: "me@example.com"
        }
        post :create, params: { store: store_hash }
        expect(response.status).to eq(201)
      end

      it "I can update an existing store" do
        store_hash = {
          url: "spree123.example.com",
          mail_from_address: "me@example.com"
        }
        put :update, params: { id: store.id, store: store_hash }
        expect(response.status).to eq(200)
        expect(store.reload.url).to eql "spree123.example.com"
        expect(store.reload.mail_from_address).to eql "me@example.com"
      end

      context "deleting a store" do
        it "will fail if it's the default Store" do
          delete :destroy, params: { id: store.id }
          expect(response.status).to eq(422)
          expect(json_response["errors"]["base"]).to eql(
            ["Cannot destroy the default Store."]
          )
        end

        it "will destroy the store" do
          delete :destroy, params: { id: non_default_store.id }
          expect(response.status).to eq(204)
        end
      end
    end

    context "as an user" do
      it "I cannot list all the stores" do
        get :index
        expect(response.status).to eq(401)
      end

      it "I cannot get the store details" do
        get :show, params: { id: store.id }
        expect(response.status).to eq(401)
      end

      it "I cannot create a new store" do
        post :create, params: {store: {}}
        expect(response.status).to eq(401)
      end

      it "I cannot update an existing store" do
        put :update, params: {id: store.id, store: {}}
        expect(response.status).to eq(401)
      end
    end
  end
end
