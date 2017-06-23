require 'spec_helper'

RSpec.describe Spree::HomeController, type: :controller do
  let(:store) { create(:store) }
  routes { Spree::Core::Engine.routes }

  before do
    reset_spree_preferences
    store.update_attributes(preferred_available_locales: %i[en es])
  end

  context 'tries not supported fr locale' do
    it 'falls back do default locale' do
      get :index, params: { locale: 'fr' }
      expect(I18n.locale).to eq :en
    end
  end

  context 'tries supported es locale' do
    it 'takes this locale' do
      get :index, params: { locale: 'es' }
      expect(I18n.locale).to eq :es
    end
  end
end
