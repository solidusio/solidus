# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::Users::WalletPaymentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:first_credit_card) { create(:credit_card, user: user, number: '4111111111111111', name: 'Peter Parker') }
  let!(:second_credit_card) { create(:credit_card, user: user, number: '5500000000000004', name: 'Auntie May') }

  before do
    user.wallet.add(first_credit_card)
    user.wallet.add(second_credit_card)
  end

  context "#index" do
    context "when user is not authorized to manage users' wallet" do
      it "denies access" do
        get :index, params: { user_id: user.id }
        expect(response).to redirect_to('/unauthorized')
      end
    end

    context "when user is authorized to manage users' wallet" do
      stub_authorization! do |_user|
        can :manage, Spree::Wallet
      end

      it "assigns @wallet_payments and returns a successful status" do
        get :index, params: { user_id: user.id }

        expect(assigns[:wallet_payments]).to match_array user.wallet_payment_sources
        expect(response).to be_successful
      end
    end
  end

  context "#destroy" do
    context "when user is not authorized to manage users wallets" do
      it "denies access" do
        get :destroy, params: { user_id: user.id, id: first_credit_card.id }
        expect(response).to redirect_to('/unauthorized')
      end
    end

    context "when user is authorized to manage users' wallet" do
      stub_authorization! do |_user|
        can :manage, Spree::Wallet
      end

      it "removes it and redirects to user's wallet with a flash message" do
        get :destroy, params: { user_id: user.id, id: first_credit_card.id }

        expect(response).to redirect_to admin_user_wallet_payments_path(user)
        expect(flash[:success]).to eq("Wallet Payment has been successfully removed!")
      end
    end
  end
end
