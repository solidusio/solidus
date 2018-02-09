module SolidusI18n
  class Locale
    def self.all
      I18n.available_locales.select do |locale|
        I18n.t(:spree, locale: locale, fallback: false, default: nil)
      end
    end
  end
end
