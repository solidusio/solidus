require 'i18n_data'

module I18n
  module Backend
    class I18nDataBackend
      module Implementation
        include Base, Flatten

        def available_locales
          I18nData.languages.keys.map(&:to_sym)
        end

        def lookup(locale, key, scope=[], options={})
          I18nData.countries(locale)[key]
        end
      end

      include Implementation
    end
  end
end

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::I18nDataBackend.new, I18n.backend)
