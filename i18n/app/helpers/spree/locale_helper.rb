module Spree
  module LocaleHelper

    def options_for_locale_select()
      Spree::Config.supported_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end

    def admin_options_for_locale_select()
      Spree::Config.all_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end
  end
end
