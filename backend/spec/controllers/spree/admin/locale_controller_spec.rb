# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::LocaleController, type: :controller do
  stub_authorization!

  before { I18n.backend.store_translations(:fr, {}) }

  after do
    I18n.locale = :en
    I18n.reload!
  end

  context 'switch_to_locale specified' do
    let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

    before do
      get :set, params: { switch_to_locale: switch_to_locale, format: :json }
    end

    context 'available locale' do
      let(:switch_to_locale) { 'fr' }

      it 'sets locale and returns the location for the redirect' do
        expect(I18n.locale).to eq :fr
        expect(session[:admin_locale]).to eq(switch_to_locale)
        expect(json_response).
          to eq({ locale: switch_to_locale,
                  location: spree.admin_url(host: 'test.host') })
        expect(response).to have_http_status(:ok)
      end
    end

    context 'unavailable locale' do
      let(:switch_to_locale) { 'klingon' }

      it 'does not change locale and returns 404' do
        expect(I18n.locale).to eq :en
        expect(json_response).to eq({ locale: 'en', })
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
