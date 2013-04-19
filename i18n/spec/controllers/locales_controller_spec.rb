require 'spec_helper'

describe Spree::HomeController do
  before(:each) do
    reset_spree_preferences
    SpreeI18n::Config.supported_locales = [:en, :es]
  end

  context "tries not supported fr locale" do
    it "falls back do default locale" do
      get :index, { use_route: :spree }, { locale: 'fr' }
      I18n.locale.should == :en
    end
  end

  context "tries supported es locale" do
    it "falls back do default locale" do
      get :index, { use_route: :spree }, { locale: 'es' }
      I18n.locale.should == :es
    end
  end
end
