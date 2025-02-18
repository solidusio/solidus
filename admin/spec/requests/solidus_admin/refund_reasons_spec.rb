# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

RSpec.describe "SolidusAdmin::RefundReasonsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:refund_reason) { create(:refund_reason) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.refund_reasons_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_refund_reason_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Refund for Defective Item", code: "DEFECT", active: true } }

      it "creates a new RefundReason" do
        expect {
          post solidus_admin.refund_reasons_path, params: { refund_reason: valid_attributes }
        }.to change(Spree::RefundReason, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.refund_reasons_path, params: { refund_reason: valid_attributes }
        expect(response).to redirect_to(solidus_admin.refund_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.refund_reasons_path, params: { refund_reason: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Refund reason was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", code: "", active: true } }

      it "does not create a new RefundReason" do
        expect {
          post solidus_admin.refund_reasons_path, params: { refund_reason: invalid_attributes }
        }.not_to change(Spree::RefundReason, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.refund_reasons_path, params: { refund_reason: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_refund_reason_path(refund_reason)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Updated Refund Reason", code: "UPD", active: false } }

      it "updates the refund reason" do
        patch solidus_admin.refund_reason_path(refund_reason), params: { refund_reason: valid_attributes }
        refund_reason.reload
        expect(refund_reason.name).to eq("Updated Refund Reason")
        expect(refund_reason.code).to eq("UPD")
        expect(refund_reason.active).to be(false)
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.refund_reason_path(refund_reason), params: { refund_reason: valid_attributes }
        expect(response).to redirect_to(solidus_admin.refund_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.refund_reason_path(refund_reason), params: { refund_reason: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Refund reason was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", code: "UPD", active: false } }

      it "does not update the refund reason" do
        original_name = refund_reason.name
        patch solidus_admin.refund_reason_path(refund_reason), params: { refund_reason: invalid_attributes }
        refund_reason.reload
        expect(refund_reason.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.refund_reason_path(refund_reason), params: { refund_reason: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the refund reason and redirects to the index page with a 303 See Other status" do
      # This ensures the refund_reason exists prior to deletion.
      refund_reason

      expect {
        delete solidus_admin.refund_reason_path(refund_reason)
      }.to change(Spree::RefundReason, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.refund_reasons_path)
      expect(response).to have_http_status(:see_other)
    end

    include_examples 'request: bulk delete resources' do
      let(:resource_factory) { :refund_reason }
      let(:bulk_delete_path) { ->(ids) { solidus_admin.refund_reasons_path(id: ids) } }
      let(:resource_class) { Spree::RefundReason }
      let(:redirect_path) { solidus_admin.refund_reasons_path }
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.refund_reason_path(refund_reason)
      follow_redirect!
      expect(response.body).to include("Refund reasons were successfully removed.")
    end
  end
end
