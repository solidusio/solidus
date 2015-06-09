module SpreeI18n
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

    # Need to manually add en to the array because the en.yml was moved from
    # this project. spree/spree now has those keys.
    def all_locales_options
      Locale.all.map { |locale| locale_presentation(locale) }.push(['English (EN)', :en])
    end

    private

    def locale_presentation(locale)
      [Spree.t(:this_file_language, scope: 'i18n', locale: locale), locale]
    end

    def common_options
      {class: 'fullwidth' , multiple: 'true'}
    end
  end
end
