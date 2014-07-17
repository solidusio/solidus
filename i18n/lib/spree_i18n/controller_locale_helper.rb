module SpreeI18n
  # The fact this logic is in a single module also helps to apply a custom
  # locale on the spree/api context since api base controller inherits from
  # MetalController instead of Spree::BaseController
  module ControllerLocaleHelper
    extend ActiveSupport::Concern
    included do
      # Ensures any existing action of the same kind and name retains its
      # position in the callback chain
      def self._stable_action(kind, name)
        # When registering a callback where one of the same kind and name already
        # exists in the chain, ActiveSupport removes the existing one and appends
        # the new one to the end, disrupting the existing chain order
        unless _process_action_callbacks.select { |c| c.kind == kind }.find { |c| c.filter == name }
          send("#{kind}_action", name)
        end
      end

      _stable_action :before, :set_user_language
      prepend_before_filter :globalize_fallbacks

      private
        # Overrides the Spree::Core::ControllerHelpers::Common logic so that only
        # supported locales defined by SpreeI18n::Config.supported_locales can
        # actually be set
        def set_user_language
          I18n.locale = if session.key?(:locale) && Config.supported_locales.include?(session[:locale].to_sym)
            session[:locale]
          elsif respond_to?(:config_locale, true) && !config_locale.blank?
            config_locale
          else
            Rails.application.config.i18n.default_locale || I18n.default_locale
          end
        end

        def globalize_fallbacks
          Fallbacks.config!
        end
    end
  end
end
