# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe TaxonsController, type: :controller do
  describe 'GET #show' do
    let!(:taxon) { create(:taxon, permalink: "test") }
    let!(:old_param) { taxon.permalink }

    before do
      taxon.update(permalink: 'new-sample-product')
    end

    context 'when permalink matches id param' do
      it 'does not redirect' do
        get :show, params: { id: taxon.permalink }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when old slug is passed' do
      it 'redirects to the correct product path' do
        get :show, params: { id: old_param }

        expect(response).to redirect_to(nested_taxons_path(taxon))
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
