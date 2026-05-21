# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Cart permissions', type: :request do
  let(:order) { create(:order, user: nil, store: store) }
  let!(:store) { create(:store) }
  let(:variant) { create(:variant) }

  context 'when an order exists in the cookies.signed', with_guest_session: true do
    before { order.update(guest_token: nil) }

    context '#edit' do
      it 'checks if user is authorized for :read' do
        get cart_path
        expect(response).to redirect_to(login_path)
      end
    end

    context '#update' do
      it 'checks if user is authorized for :update' do
        patch cart_path, params: { order: { email: "foo@bar.com" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context '#empty' do
      it 'checks if user is authorized for :update' do
        put empty_cart_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
