module SolidusI18n
  module AddAvailableLanguagesPreferenceToStore
    def self.prepended(base)
      base.preference :available_locales, :array, default: [:en]
    end

    def preferred_available_locales
      super.map(&:to_sym)
    end
  end

  Spree::Store.prepend AddAvailableLanguagesPreferenceToStore
end
