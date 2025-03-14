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
  let(:invalid_reason_params) { { store_credit_reason_id: nil } }
  let(:valid_create_params) do
    {
      store_credit: {
        amount: 150,
        currency: "USD",
        category_id: create(:store_credit_category).id,
        memo: "Initial store credit"
      }
    }
  end

  let(:invalid_create_amount_params) do
    {
      store_credit: {
        amount: nil,
        currency: "USD",
        category_id: create(:store_credit_category).id,
        memo: "Invalid store credit"
      }
    }
  end

  let(:invalid_create_category_params) do
    {
      store_credit: {
        amount: 100,
        currency: "USD",
        category_id: nil,
        memo: "Invalid store credit"
      }
    }
  end

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

  describe "GET /new" do
    it "renders the new store credit template with a 200 OK status" do
      get solidus_admin.new_user_store_credit_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new store credit" do
        expect {
          post solidus_admin.user_store_credits_path(user), params: valid_create_params
        }.to change(Spree::StoreCredit, :count).by(1)
      end

      context "for html requests" do
        it "redirects to the store credits index page with a success message" do
          post solidus_admin.user_store_credits_path(user), params: valid_create_params
          expect(response).to redirect_to(solidus_admin.user_store_credits_path(user))
          follow_redirect!
          expect(response.body).to include("Store credit was successfully created.")
        end
      end

      context "for turbo_stream requests" do
        it "returns a turbo_stream response when requested" do
          post solidus_admin.user_store_credits_path(user, format: :turbo_stream), params: valid_create_params
          expect(response).to redirect_to(solidus_admin.user_store_credits_path(user))
          follow_redirect!
          expect(response.body).to include("Store credit was successfully created.")
        end
      end
    end

    context "with invalid amount parameters" do
      it "does not create a new store credit" do
        expect {
          post solidus_admin.user_store_credits_path(user), params: invalid_create_amount_params
        }.not_to change(Spree::StoreCredit, :count)
      end

      it "renders the new template with amount errors" do
        post solidus_admin.user_store_credits_path(user), params: invalid_create_amount_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("must be greater than 0")
      end
    end

    context "with invalid category parameters" do
      it "does not create a new store credit" do
        expect {
          post solidus_admin.user_store_credits_path(user), params: invalid_create_category_params
        }.not_to change(Spree::StoreCredit, :count)
      end

      it "renders the new template with category errors" do
        post solidus_admin.user_store_credits_path(user), params: invalid_create_category_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Store credit category must be provided")
      end
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

      context "when update_amount fails" do
        before do
          allow_any_instance_of(Spree::StoreCredit).to receive(:update_amount).and_return(false)
        end

        it "renders the edit_amount template with errors" do
          put solidus_admin.update_amount_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }

          expect(response).to have_http_status(:unprocessable_entity)
        end
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

  describe "GET /edit_validity" do
    it "renders the edit_validity template with a 200 OK status" do
      get solidus_admin.edit_validity_user_store_credit_path(user, store_credit)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Choose Reason For Invalidating")
    end
  end

  describe "PUT /invalidate" do
    context "with valid parameters" do
      let(:store_credit_reason) { create(:store_credit_reason) }

      it "invalidates the store credit" do
        expect {
          put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: { store_credit_reason_id: store_credit_reason.id } }
        }.to change { store_credit.reload.invalidated? }.from(false).to(true)
      end

      it "redirects to the store credit show page with a 303 See Other status" do
        put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: { store_credit_reason_id: store_credit_reason.id } }
        expect(response).to redirect_to(solidus_admin.user_store_credit_path(user, store_credit))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: { store_credit_reason_id: store_credit_reason.id } }
        follow_redirect!
        expect(response.body).to include("Store credit was successfully invalidated.")
      end
    end

    context "with invalid parameters" do
      it "does not invalidate the store credit" do
        expect {
          put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: invalid_reason_params }
        }.not_to change { store_credit.reload.invalidated? }
      end

      it "renders the edit_validity template with unprocessable_entity status" do
        put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: invalid_reason_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays error messages in the response" do
        put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: invalid_reason_params }
        expect(response.body).to include("Store credit reason must be provided")
      end
    end

    context "when the database update fails" do
      before do
        allow_any_instance_of(Spree::StoreCredit).to receive(:invalidate).and_return(false)
      end

      it "does not invalidate the store credit" do
        expect {
          put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }
        }.not_to change { store_credit.reload.invalidated? }
      end

      it "redirects to the store credit show page with a 303 See Other status" do
        put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }
        expect(response).to redirect_to(solidus_admin.user_store_credit_path(user, store_credit))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a failure flash message" do
        put solidus_admin.invalidate_user_store_credit_path(user, store_credit), params: { store_credit: valid_params }
        follow_redirect!
        expect(response.body).to include("Something went wrong. Store credit could not be invalidated.")
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
        expect(response.body).to include("Store credit reason must be provided")
      end
    end

    describe "private methods" do
      describe "#ensure_store_credit_category" do
        it "adds an error when category_id is blank" do
          post solidus_admin.user_store_credits_path(user), params: { store_credit: { amount: 100, category_id: nil } }
          expect(response.body).to include("Store credit category must be provided")
        end
      end
    end
  end
end
