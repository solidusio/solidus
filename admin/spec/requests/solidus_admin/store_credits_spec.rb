# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::StoreCreditsController, type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }
  let!(:store_credit) { create(:store_credit, user:) }
  let!(:store_credit_event) { create(:store_credit_adjustment_event, store_credit:, amount_remaining: 50) }
  let(:valid_params) { { amount: 100, store_credit_reason_id: create(:store_credit_reason).id } }
  let(:invalid_params) { { amount: nil } }
  let(:valid_memo_params) { { memo: "Updated memo text" } }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the store credits template with a 200 OK status" do
      get solidus_admin.user_store_credits_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(store_credit.amount.to_s)
    end
  end

  describe "GET /show" do
    it "renders the store credit show page with a 200 OK status" do
      get solidus_admin.user_store_credit_path(user, store_credit)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(store_credit.amount.to_s)
    end
  end

  describe "GET /edit_amount" do
    it "renders the edit_amount template with a 200 OK status" do
      get solidus_admin.edit_amount_user_store_credit_path(user, store_credit)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(store_credit.amount.to_s)
    end
  end

  describe "PUT /update_amount" do
    context "with valid parameters" do
      it "updates the store credit amount" do
        expect {
          put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }
        }.to change { store_credit.reload.amount }.to(100)
      end

      it "redirects to the store credit show page with a 303 See Other status" do
        put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }
        expect(response).to redirect_to(solidus_admin.user_store_credit_path(user, store_credit))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }
        follow_redirect!
        expect(response.body).to include("Store credit was successfully updated.")
      end
    end

    context "with invalid parameters" do
      it "does not update the store credit amount" do
        expect {
          put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: invalid_params }
        }.not_to change { store_credit.reload.amount }
      end

      it "renders the edit_amount template with unprocessable_entity status" do
        put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays error messages in the response" do
        put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: invalid_params }
        expect(response.body).to include("must be greater than 0")
      end
    end
  end

  describe "GET /edit_memo" do
    it "renders the edit_memo template with a 200 OK status" do
      get solidus_admin.edit_memo_user_store_credit_path(user, store_credit)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(store_credit.memo.to_s)
    end
  end

  describe "PUT /update_memo" do
    context "with valid parameters" do
      it "updates the store credit memo" do
        expect {
          put solidus_admin.update_memo_user_store_credit_path(user, store_credit), params: { store_credit: valid_memo_params }
        }.to change { store_credit.reload.memo }.to("Updated memo text")
      end

      it "redirects to the store credit show page with a 303 See Other status" do
        put solidus_admin.update_memo_user_store_credit_path(user, store_credit), params: { store_credit: valid_memo_params }
        expect(response).to redirect_to(solidus_admin.user_store_credit_path(user, store_credit))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        put solidus_admin.update_memo_user_store_credit_path(user, store_credit), params: { store_credit: valid_memo_params }
        follow_redirect!
        expect(response.body).to include("Store credit was successfully updated.")
      end
    end

    context "when the database update fails" do
      before do
        # Memo update failures are nearly impossible to trigger due to lack of validation.
        allow_any_instance_of(Spree::StoreCredit).to receive(:update).and_return(false)
      end

      it "does not update the store credit memo" do
        expect {
          put solidus_admin.update_memo_user_store_credit_path(user, store_credit), params: { store_credit: valid_memo_params }
        }.not_to change { store_credit.reload.memo }
      end

      it "redirects to the store credit show page with a 303 See Other status" do
        put solidus_admin.update_memo_user_store_credit_path(user, store_credit), params: { store_credit: valid_memo_params }
        expect(response).to redirect_to(solidus_admin.user_store_credit_path(user, store_credit))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a failure flash message" do
        put solidus_admin.update_memo_user_store_credit_path(user, store_credit), params: { store_credit: valid_memo_params }
        follow_redirect!
        expect(response.body).to include("Something went wrong. Store credit could not be updated.")
      end
    end
  end

  describe "private methods" do
    describe "#ensure_amount" do
      it "adds an error when the amount is blank" do
        put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: invalid_params }
        expect(response.body).to include("must be greater than 0")
      end
    end

    describe "#ensure_store_credit_reason" do
      it "adds an error when the store credit reason is blank" do
        put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: { amount: 100, store_credit_reason_id: nil } }
        expect(response.body).to include("Store Credit reason must be provided")
      end
    end
  end
end
