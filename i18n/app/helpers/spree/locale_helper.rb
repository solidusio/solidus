module Spree
  module LocaleHelper

    def options_for_locale_select()
      SpreeI18n::Config.supported_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end

    def admin_options_for_locale_select()
      SpreeI18n::Config.available_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end
  end
end
