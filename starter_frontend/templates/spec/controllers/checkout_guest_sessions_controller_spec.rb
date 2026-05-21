# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe CheckoutGuestSessionsController, type: :controller do
  let(:order) { create(:order_with_line_items, email: nil, user: nil, guest_token: token) }
  let(:user)  { build(:user, spree_api_key: 'fake') }
  let(:token) { 'some_token' }
  let(:cookie_token) { token }

  before do
    request.cookie_jar.signed[:guest_token] = cookie_token
    allow(controller).to receive(:current_order) { order }
  end

  context '#create' do
    subject { post :create, params: { order: { email: email } } }
    let(:email) { 'foo@example.com' }

    it 'does not check registration' do
      expect(controller).not_to receive(:check_registration)
      subject
    end

    it 'redirects to the checkout_path after saving' do
      subject
      expect(response).to redirect_to checkout_path
    end

    # Regression test for https://github.com/solidusio/solidus/issues/1588
    context 'order in address state' do
      let(:order) do
        create(
          :order_with_line_items,
          email: nil,
          user: nil,
          guest_token: token,
          bill_address: nil,
          ship_address: nil,
          state: 'address'
        )
      end

      # This may seem out of left field, but previously there was an issue
      # where address would be built in a before filter and then would be saved
      # when trying to update the email.
      it "doesn't create addresses" do
        expect {
          subject
        }.not_to change { Spree::Address.count }
        expect(response).to redirect_to checkout_path
      end
    end

    context 'invalid email' do
      let(:email) { 'invalid' }

      it 'renders the registration view' do
        subject
        expect(flash[:registration_error]).to eq I18n.t(:email_is_invalid, scope: [:errors, :messages])
        expect(response).to render_template 'checkout_sessions/new'
      end
    end

    context 'with wrong order token' do
      let(:cookie_token) { 'lol_no_access' }

      it 'redirects to login' do
        subject
        expect(response).to redirect_to(login_path)
      end
    end

    context 'without order token' do
      let(:cookie_token) { nil }

      it 'redirects to login' do
        subject
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
