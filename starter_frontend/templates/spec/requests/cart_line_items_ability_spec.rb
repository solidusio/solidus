# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Cart line item permissions', type: :request do
  let(:order) { create(:order, user: nil, store: store) }
  let!(:store) { create(:store) }
  let(:variant) { create(:variant) }

  context 'when an order exists in the cookies.signed', with_guest_session: true do
    before { order.update(guest_token: nil) }

    context '#create' do
      it 'checks if user is authorized for :update' do
        post cart_line_items_path, params: { variant_id: variant.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
