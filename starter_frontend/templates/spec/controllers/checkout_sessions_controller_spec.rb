# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe CheckoutSessionsController, type: :controller do
  let(:order) { create(:order_with_line_items, email: nil, user: nil, guest_token: token) }
  let(:user)  { build(:user, spree_api_key: 'fake') }
  let(:token) { 'some_token' }
  let(:cookie_token) { token }

  before do
    request.cookie_jar.signed[:guest_token] = cookie_token
    allow(controller).to receive(:current_order) { order }
  end

  context '#new' do
    it 'checks if the user is authorized for :edit' do
      expect(controller).to receive(:authorize!).with(:edit, order, token)
      request.cookie_jar.signed[:guest_token] = token
      get :new, params: {}
    end
  end
end
