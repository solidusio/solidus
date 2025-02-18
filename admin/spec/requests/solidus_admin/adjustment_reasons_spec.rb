# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::AdjustmentReasonsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:adjustment_reason) { create(:adjustment_reason) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.adjustment_reasons_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_adjustment_reason_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { {name: "Price Adjustment", code: "PRICE_ADJUST", active: true} }

      it "creates a new AdjustmentReason" do
        expect {
          post solidus_admin.adjustment_reasons_path, params: {adjustment_reason: valid_attributes}
        }.to change(Spree::AdjustmentReason, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.adjustment_reasons_path, params: {adjustment_reason: valid_attributes}
        expect(response).to redirect_to(solidus_admin.adjustment_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.adjustment_reasons_path, params: {adjustment_reason: valid_attributes}
        follow_redirect!
        expect(response.body).to include("Adjustment reason was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {name: "", code: "", active: true} }

      it "does not create a new AdjustmentReason" do
        expect {
          post solidus_admin.adjustment_reasons_path, params: {adjustment_reason: invalid_attributes}
        }.not_to change(Spree::AdjustmentReason, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.adjustment_reasons_path, params: {adjustment_reason: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_adjustment_reason_path(adjustment_reason)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { {name: "Updated Adjustment Reason", code: "UPD_ADJ", active: false} }

      it "updates the adjustment reason" do
        patch solidus_admin.adjustment_reason_path(adjustment_reason), params: {adjustment_reason: valid_attributes}
        adjustment_reason.reload
        expect(adjustment_reason.name).to eq("Updated Adjustment Reason")
        expect(adjustment_reason.code).to eq("UPD_ADJ")
        expect(adjustment_reason.active).to be(false)
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.adjustment_reason_path(adjustment_reason), params: {adjustment_reason: valid_attributes}
        expect(response).to redirect_to(solidus_admin.adjustment_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.adjustment_reason_path(adjustment_reason), params: {adjustment_reason: valid_attributes}
        follow_redirect!
        expect(response.body).to include("Adjustment reason was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {name: "", code: "UPD_ADJ", active: false} }

      it "does not update the adjustment reason" do
        original_name = adjustment_reason.name
        patch solidus_admin.adjustment_reason_path(adjustment_reason), params: {adjustment_reason: invalid_attributes}
        adjustment_reason.reload
        expect(adjustment_reason.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.adjustment_reason_path(adjustment_reason), params: {adjustment_reason: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the adjustment reason and redirects to the index page with a 303 See Other status" do
      # This ensures the adjustment_reason exists prior to deletion.
      adjustment_reason

      expect {
        delete solidus_admin.adjustment_reason_path(adjustment_reason)
      }.to change(Spree::AdjustmentReason, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.adjustment_reasons_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.adjustment_reason_path(adjustment_reason)
      follow_redirect!
      expect(response.body).to include("Adjustment reasons were successfully removed.")
    end
  end
end
