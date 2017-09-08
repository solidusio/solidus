module SolidusI18n
  module LocaleHelper
    def select_available_locales(store = nil)
      select_tag('store[preferred_available_locales][]',
                 options_for_select(
                   all_locales_options,
                   store.preferred_available_locales
                 ), common_options)
    end

    def available_locales_options
      current_store.preferred_available_locales.map { |locale| locale_presentation(locale) }
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
