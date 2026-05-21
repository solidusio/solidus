# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Order permissions', type: :request do
  let(:order) { create(:order, user: nil, store: store) }
  let!(:store) { create(:store) }
  let(:variant) { create(:variant) }

  it 'understands order routes with token' do
    expect(token_order_path('R123456', 'ABCDEF')).to eq('/orders/R123456/token/ABCDEF')
  end

  context 'when an order exists in the cookies.signed', with_guest_session: true do
    before { order.update(guest_token: nil) }

    context "#show" do
      it "checks against the specified order" do
        get order_path(id: order.number)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  context 'when no authenticated user' do
    let(:order) { create(:order, number: 'R123') }
    let(:another_order) { create(:order) }

    context '#show' do
      context 'when token parameter present' do
        it 'always override existing token when passing a new one' do
          get order_path(id: another_order.number, token: another_order.guest_token)
          jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
          expect(jar.signed[:guest_token]).to eq another_order.guest_token
        end

        it 'stores as guest_token in session' do
          get order_path(id: order.number, token: order.guest_token)
          jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
          expect(jar.signed[:guest_token]).to eq order.guest_token
        end
      end

      context 'when no token present' do
        it 'responds with 404' do
          get order_path(id: 'R123')

          expect(response.status).to eq(404)
        end
      end
    end
  end
end
