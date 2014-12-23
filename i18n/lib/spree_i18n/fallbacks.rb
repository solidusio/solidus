module SpreeI18n
  module Fallbacks
    # Prevents the app from breaking when a translation is not present on the
    # default locale. It should search for translations in all supported
    # locales
    #
    # It needs to build a proper key value hash for every locale. So that a locale
    # always fallbacks to itself first before looking at the default and then
    # to any other. e.g
    #
    #   supported_locales = [:es, :de, :en]
    #
    #   # right
    #   { en: [:en, :de, :es], es: [:es, :en, :de] .. }
    #
    #   # wrong, spanish locale would fallback to english first
    #   { en: [:en, :es], es: [:en, :es] }
    #
    #   # wrong, spanish locale would fallback to german first instead of :en (default)
    #   { en: [:en, :de, :es], es: [:es, :de, :en] .. }
    #
    def self.config!
      supported = SpreeI18n::Config.supported_locales
      default = I18n.default_locale

      Globalize.fallbacks = supported.inject({}) do |fallbacks, locale|
        if locale.to_sym == default
          fallbacks.merge(locale => [locale].push(supported-[locale]).flatten)
        else
          fallbacks.merge(locale => [locale, default].push(supported-[locale, default]).flatten)
        end
      end
    end
  end
end
