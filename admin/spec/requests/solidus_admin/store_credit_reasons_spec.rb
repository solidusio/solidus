# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::StoreCreditReasonsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:store_credit_reason) { create(:store_credit_reason) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.store_credit_reasons_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_store_credit_reason_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { {name: "Customer Loyalty", active: true} }

      it "creates a new StoreCreditReason" do
        expect {
          post solidus_admin.store_credit_reasons_path, params: {store_credit_reason: valid_attributes}
        }.to change(Spree::StoreCreditReason, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.store_credit_reasons_path, params: {store_credit_reason: valid_attributes}
        expect(response).to redirect_to(solidus_admin.store_credit_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.store_credit_reasons_path, params: {store_credit_reason: valid_attributes}
        follow_redirect!
        expect(response.body).to include("Store credit reason was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {name: "", active: true} }

      it "does not create a new StoreCreditReason" do
        expect {
          post solidus_admin.store_credit_reasons_path, params: {store_credit_reason: invalid_attributes}
        }.not_to change(Spree::StoreCreditReason, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.store_credit_reasons_path, params: {store_credit_reason: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_store_credit_reason_path(store_credit_reason)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { {name: "Updated Reason", active: false} }

      it "updates the store credit reason" do
        patch solidus_admin.store_credit_reason_path(store_credit_reason), params: {store_credit_reason: valid_attributes}
        store_credit_reason.reload
        expect(store_credit_reason.name).to eq("Updated Reason")
        expect(store_credit_reason.active).to be(false)
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.store_credit_reason_path(store_credit_reason), params: {store_credit_reason: valid_attributes}
        expect(response).to redirect_to(solidus_admin.store_credit_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.store_credit_reason_path(store_credit_reason), params: {store_credit_reason: valid_attributes}
        follow_redirect!
        expect(response.body).to include("Store credit reason was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {name: "", active: false} }

      it "does not update the store credit reason" do
        original_name = store_credit_reason.name
        patch solidus_admin.store_credit_reason_path(store_credit_reason), params: {store_credit_reason: invalid_attributes}
        store_credit_reason.reload
        expect(store_credit_reason.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.store_credit_reason_path(store_credit_reason), params: {store_credit_reason: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the store credit reason and redirects to the index page with a 303 See Other status" do
      # This ensures the store_credit_reason exists prior to deletion.
      store_credit_reason

      expect {
        delete solidus_admin.store_credit_reason_path(store_credit_reason)
      }.to change(Spree::StoreCreditReason, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.store_credit_reasons_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.store_credit_reason_path(store_credit_reason)
      follow_redirect!
      expect(response.body).to include("Store credit reasons were successfully removed.")
    end
  end
end
