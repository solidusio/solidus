module SpreeI18n
  module LocaleHelper
    def select_supported_locales
      select_tag('supported_locales[]', options_for_select(available_locales_options, Config.supported_locales), common_options)
    end

    def select_available_locales
      select_tag('available_locales[]', options_for_select(all_locales_options, Config.available_locales), common_options)
    end

    def select_available_locales_fields
      select_tag('locale', options_for_select(all_locales_options, Config.available_locales), common_options)
    end

    def supported_locales_options
      Config.supported_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end

    def available_locales_options
      Config.available_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end

    def all_locales_options
      I18n.available_locales.map do |locale|
        [I18n.t(:this_file_language, :locale => locale), locale]
      end
    end

      private
        def common_options
          { :class => 'fullwidth' , :multiple => 'true' }
        end
  end
end
