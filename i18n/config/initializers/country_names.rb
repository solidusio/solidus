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
          begin
            I18nData.countries(locale)[key]
          rescue I18nData::NoTranslationAvailable
            # rescue failed lookup to fall back to this extensions locale files.
          end
        end
      end

      include Implementation
    end
  end
end

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::I18nDataBackend.new, I18n.backend)


module I18nData

  private
  def self.normal_to_region_code(normal)
    country_mappings = {
      "DE-CH" => "de",
      "FR-CH" => "fr",
      "EN-AU" => "en",
      "EN-GB" => "en",
      "EN-US" => "en",
      "EN-IN" => "en",
      "EN-NZ" => "en",
      "ES-CL" => "es",
      "ES-EC" => "es",
      "ES-MX" => "es",
      "PT-BR" => "pt",
      "SL-SI" => "sl",
      "ZH-TW" => "zh_CN",
      "ZH-CN" => "zh_CN",
      "ZH" => "zh_CN",
      "BN" => "bn_IN",
      }
    country_mappings[normal] || normal
  end
end
