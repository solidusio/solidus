module Spree
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: Rails.application.config.i18n.default_locale

    def menu
      @menu ||= Spree::Admin::Menu.new
    end
  end
end
