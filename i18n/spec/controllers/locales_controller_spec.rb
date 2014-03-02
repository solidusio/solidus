require 'spec_helper'

describe Spree::HomeController do
  before do
    reset_spree_preferences
    SpreeI18n::Config.supported_locales = [:en, :es]
  end

  context "tries not supported fr locale" do
    it "falls back do default locale" do
      get :index, { use_route: :spree }, { locale: 'fr' }
      expect(I18n.locale).to eq :en
    end
  end

  context "tries supported es locale" do
    it "falls back do default locale" do
      get :index, { use_route: :spree }, { locale: 'es' }
      expect(I18n.locale).to eq :es
    end
  end
end
