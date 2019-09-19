# frozen_string_literal: true

require 'spec_helper'

shared_examples "update reason loader" do
  it "sets the store_credit_reasons variable to a list of categories sorted by category name " do
    expect(assigns(:store_credit_reasons)).to eq [store_credit_reason]
  end
end

describe Spree::Admin::StoreCreditsController do
  stub_authorization!

  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }

  let!(:b_credit_category) { create(:store_credit_category, name: "B category") }
  let!(:a_credit_category) { create(:store_credit_category, name: "A category") }
  let!(:store_credit_reason) { create(:store_credit_reason) }

  describe "#show" do
    let!(:store_credit) { create(:store_credit, user: user, category: a_credit_category) }
    let!(:event) { create(:store_credit_auth_event, store_credit: store_credit, created_at: 5.days.ago) }

    before { get :show, params: { user_id: user.id, id: store_credit.id  } }

    it "sets the store_credit variable to a new store credit model" do
      expect(assigns(:store_credit)).to eq store_credit
    end

    it "sets the store_credit_events variable to the store credit's events in chronological order" do
      allocation_event = store_credit.store_credit_events.find_by(action: Spree::StoreCredit::ALLOCATION_ACTION)
      expect(assigns(:store_credit_events)).to eq [event, allocation_event]
    end
  end

  describe "#new" do
    before { get :new, params: { user_id: create(:user).id } }
    it { expect(assigns(:credit_categories)).to eq [a_credit_category, b_credit_category] }
  end

  describe "#create" do
    subject { post :create, params: parameters }

    before  {
      allow(controller).to receive_messages(try_spree_current_user: admin_user)
      create(:primary_credit_type)
    }

    context "the passed parameters are valid" do
      let(:parameters) do
        {
          user_id: user.id,
          store_credit: {
            amount: 1.00,
            currency: "USD",
            category_id: a_credit_category.id
          }
        }
      end

      it "creates a new store credit" do
        expect { subject }.to change(Spree::StoreCredit, :count).by(1)
      end

      it "associates the store credit with the user" do
        subject
        expect(user.reload.store_credits.count).to eq 1
      end

      it "assigns the store credit's created by to the current user" do
        subject
        expect(user.reload.store_credits.first.created_by).to eq admin_user
      end

      it 'sets the admin as the store credit event originator' do
        expect { subject }.to change { Spree::StoreCreditEvent.count }.by(1)
        expect(Spree::StoreCreditEvent.last.originator).to eq admin_user
      end
    end

    context "the passed parameters are invalid" do
      let(:parameters) do
        {
          user_id: user.id,
          store_credit: {
            amount: -1.00,
            category_id: a_credit_category.id
          }
        }
      end

      it { expect { subject }.not_to change(Spree::StoreCredit, :count) }
    end
  end

  describe "#edit_amount" do
    let!(:store_credit) { create(:store_credit, user: user, category: a_credit_category) }

    before { get :edit_amount, params: { user_id: user.id, id: store_credit.id } }

    it_behaves_like "update reason loader"

    it "sets the store_credit variable to the persisted store credit" do
      expect(assigns(:store_credit)).to eq store_credit
    end
  end

  describe "#edit_validity" do
    let!(:store_credit) { create(:store_credit, user: user, category: a_credit_category) }

    before { get :edit_validity, params: { user_id: user.id, id: store_credit.id } }

    it_behaves_like "update reason loader"

    it "sets the store_credit variable to the persisted store credit" do
      expect(assigns(:store_credit)).to eq store_credit
    end
  end

  describe "#update" do
    let(:memo)          { "New memo" }
    let!(:store_credit) { create(:store_credit, user: user) }

    subject { put :update, params: parameters.merge(format: :json) }

    before  { allow(controller).to receive_messages(try_spree_current_user: admin_user) }

    context "the passed parameters are valid" do
      let(:parameters) do
        {
          user_id: user.id,
          id: store_credit.id,
          store_credit: {
            memo: memo
          }
        }
      end

      it "updates the memo to be the passed in value" do
        expect { subject }.to change { store_credit.reload.memo }.to(memo)
      end

      it "returns a success message" do
        subject
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to match("Store Credit has been successfully updated!")
      end
    end

    context "the passed parameters are invalid" do
      let(:parameters) do
        {
          user_id: user.id,
          id: store_credit.id,
          store_credit: {
            category_id: b_credit_category.id
          }
        }
      end
      it "doesn't update the store credit's category" do
        expect { subject }.to_not change { store_credit.reload.category }
      end

      it "returns an error message" do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['message']).to match("Unable to update store credit")
      end
    end
  end

  describe "#update_amount" do
    let(:original_amount) { 100.0 }
    let!(:store_credit)   { create(:store_credit, user: user, amount: original_amount) }
    let!(:store_credit_reason) { create(:store_credit_reason) }
    let(:parameters) do
      {
        user_id: user.id,
        id: store_credit.id,
        store_credit_reason_id: store_credit_reason.id,
        store_credit: {
          amount: updated_amount
        }
      }
    end

    subject { put :update_amount, params: parameters }

    before  { allow(controller).to receive_messages(try_spree_current_user: admin_user) }

    context "the passed parameters are valid" do
      let(:updated_amount) { 300.0 }

      context "the store credit has been partially used" do
        before { store_credit.update(amount_used: 10.0) }

        context "the new amount is greater than the used amount" do
          let(:updated_amount) { 11.0 }

          before { subject }

          it "updates the amount to be the passed in amount" do
            expect(store_credit.reload.amount).to eq updated_amount
          end
        end

        context "the new amount is less than the used amount" do
          let(:updated_amount) { 9.0 }

          before { subject }

          it "does not update the amount" do
            expect(store_credit.reload.amount).to eq original_amount
          end

          it "renders the edit_amount template" do
            expect(response).to render_template :edit_amount
          end

          it "adds an error message to the flash" do
            expect(flash.now[:error]).to match "Unable to update"
          end

          it_behaves_like "update reason loader"
        end
      end

      context "the store credit has not been used" do
        it "sets a success message in the flash" do
          subject
          expect(flash.now[:success]).to match "Store Credit has been successfully updated!"
        end

        it "does not create a new store credit" do
          expect { subject }.to_not change(Spree::StoreCredit, :count)
        end

        it "updates passed amount" do
          subject
          expect(store_credit.reload.amount).to eq updated_amount
        end
      end
    end

    context "the passed parameters are invalid" do
      let(:updated_amount) { -1.00 }

      before { subject }

      it "does not update the amount" do
        expect(store_credit.reload.amount).to eq original_amount
      end

      it "renders the edit_amount template" do
        expect(response).to render_template :edit_amount
      end

      it "adds an error message to the flash" do
        expect(flash.now[:error]).to match "Unable to update"
      end

      it_behaves_like "update reason loader"
    end
  end

  describe "#invalidate" do
    let!(:store_credit) { create(:store_credit, user: user, category: b_credit_category) }

    let(:parameters) do
      {
        user_id: user.id,
        id: store_credit.id,
        store_credit_reason_id: store_credit_reason.id
      }
    end

    subject { put :invalidate, params: parameters }

    it "attempts to invalidate the store credit" do
      expect { subject }.to change { store_credit.reload.invalidated_at }.from(nil)
    end

    context "the invalidation is unsuccessful" do
      before do
        store_credit.authorize(5.0, "USD")
        subject
      end

      it "doesn't invalidate the store credit" do
        expect(store_credit.reload.invalidated_at).to be_nil
      end

      it "renders the edit_validity template" do
        expect(response).to render_template :edit_validity
      end

      it "sets an error message in the flash" do
        expect(flash.now[:error]).to match "Unable to invalidate store credit"
      end

      it_behaves_like "update reason loader"
    end

    context "the invalidation is successful" do
      it "redirects to index" do
        expect(subject).to redirect_to spree.admin_user_store_credit_path(user, store_credit)
      end
    end
  end
end
