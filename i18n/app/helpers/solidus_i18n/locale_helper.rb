module SolidusI18n
  module LocaleHelper

    def select_available_locales
      select_tag('available_locales[]', options_for_select(
        all_locales_options,
        Config.available_locales
      ), common_options)
    end

    def available_locales_options
      Config.available_locales.map { |locale| locale_presentation(locale) }
    end

    def all_locales_options
      SolidusI18n::Locale.all.map { |locale| locale_presentation(locale) }
    end

    private

    def locale_presentation(locale)
      [Spree.t(:'i18n.this_file_language', locale: locale), locale]
    end

    def common_options
      { class: 'fullwidth', multiple: 'true' }
    end
  end
end
