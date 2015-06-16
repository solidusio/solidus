RSpec.describe Spree::HomeController, type: :controller do
  routes { Spree::Core::Engine.routes }

  before do
    reset_spree_preferences
    SpreeI18n::Config.available_locales = [:en, :es]
  end

  context "tries not supported fr locale" do
    it "falls back do default locale" do
      get :index, locale: 'fr'
      expect(I18n.locale).to eq :en
    end
  end

  context "tries supported es locale" do
    it "takes this locale" do
      get :index, locale: 'es'
      expect(I18n.locale).to eq :es
    end
  end
end
