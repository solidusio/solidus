# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:product) { create(:product, available_on: 1.year.from_now) }
  let!(:user)    { build(:user, spree_api_key: 'fake') }

  it 'allows admins to view non-active products' do
    allow(controller).to receive(:spree_current_user) { user }
    allow(user).to receive(:has_spree_role?) { true }
    get :show, params: { id: product.to_param }
    expect(response.status).to eq(200)
  end

  it 'cannot view non-active products' do
    allow(controller).to receive(:spree_current_user) { user }
    allow(user).to receive(:has_spree_role?) { false }

    expect do
      get :show, params: { id: product.to_param }
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'GET #show' do
    let!(:product) { create(:product, slug: 'sample-product') }

    before do
      product.update(slug: 'new-sample-product')
    end

    context 'when slug matches id param' do
      it 'does not redirect' do
        get :show, params: { id: product.slug }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when old slug is passed' do
      it 'redirects to the correct product path' do
        get :show, params: { id: 'sample-product' }

        expect(response).to redirect_to(product_path(product))
        expect(response.status).to eq(301)
      end
    end

    context 'when id is passed' do
      it 'redirects to the correct product path' do
        get :show, params: { id: product.id }

        expect(response).to redirect_to(product_path(product))
        expect(response.status).to eq(301)
      end
    end

    context 'when slug does not match id param and product does not exist' do
      it 'returns 404' do
        expect do
          get :show, params: { id: 'non-existent-slug' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
