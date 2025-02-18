# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::ReturnReasonsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:return_reason) { create(:return_reason) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.return_reasons_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_return_reason_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_return_reason_path(return_reason)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { {name: "Updated Return Reason", active: false} }

      it "updates the return reason" do
        patch solidus_admin.return_reason_path(return_reason), params: {return_reason: valid_attributes}
        return_reason.reload
        expect(return_reason.name).to eq("Updated Return Reason")
        expect(return_reason.active).to be(false)
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.return_reason_path(return_reason), params: {return_reason: valid_attributes}
        expect(response).to redirect_to(solidus_admin.return_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.return_reason_path(return_reason), params: {return_reason: valid_attributes}
        follow_redirect!
        expect(response.body).to include("Return reason was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {name: "", active: false} }

      it "does not update the return reason" do
        original_name = return_reason.name
        patch solidus_admin.return_reason_path(return_reason), params: {return_reason: invalid_attributes}
        return_reason.reload
        expect(return_reason.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.return_reason_path(return_reason), params: {return_reason: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { {name: "Damaged item", active: true} }

      it "creates a new ReturnReason" do
        expect {
          post solidus_admin.return_reasons_path, params: {return_reason: valid_attributes}
        }.to change(Spree::ReturnReason, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.return_reasons_path, params: {return_reason: valid_attributes}
        expect(response).to redirect_to(solidus_admin.return_reasons_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.return_reasons_path, params: {return_reason: valid_attributes}
        follow_redirect!
        expect(response.body).to include("Return reason was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { {name: ""} }

      it "does not create a new ReturnReason" do
        expect {
          post solidus_admin.return_reasons_path, params: {return_reason: invalid_attributes}
        }.not_to change(Spree::ReturnReason, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.return_reasons_path, params: {return_reason: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:return_reason_to_delete) { create(:return_reason) }

    it "deletes the return reason and redirects to the index page with a 303 See Other status" do
      expect {
        delete solidus_admin.return_reason_path(return_reason_to_delete)
      }.to change(Spree::ReturnReason, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.return_reasons_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.return_reason_path(return_reason_to_delete)
      follow_redirect!
      expect(response.body).to include("Return reasons were successfully removed.")
    end
  end
end
