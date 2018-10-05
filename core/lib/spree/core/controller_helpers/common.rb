# frozen_string_literal: true

require 'carmen'

module Spree
  module Core
    module ControllerHelpers
      module Common
        extend ActiveSupport::Concern
        included do
          helper_method :title
          helper_method :title=
          helper_method :accurate_title

          layout :get_layout

          before_action :set_user_language
        end

        protected

        # can be used in views as well as controllers.
        # e.g. <% self.title = 'This is a custom title for this view' %>
        attr_writer :title

        def title
          title_string = @title.present? ? @title : accurate_title
          if title_string.present?
            if Spree::Config[:always_put_site_name_in_title]
              [title_string, default_title].join(' - ')
            else
              title_string
            end
          else
            default_title
          end
        end

        def default_title
          current_store.name
        end

        # this is a hook for subclasses to provide title
        def accurate_title
          current_store.seo_title
        end

        private

        def set_user_language_locale_key
          :locale
        end

        def set_user_language
          available_locales = Spree.i18n_available_locales
          locale = [
            params[:locale],
            session[set_user_language_locale_key],
            (config_locale if respond_to?(:config_locale, true)),
            I18n.default_locale
          ].detect do |candidate|
            candidate &&
              available_locales.include?(candidate.to_sym)
          end
          session[set_user_language_locale_key] = locale
          I18n.locale = locale
          Carmen.i18n_backend.locale = locale
        end

        # Returns which layout to render.
        #
        # You can set the layout you want to render inside your Spree configuration with the +:layout+ option.
        #
        # Default layout is: +app/views/spree/layouts/spree_application+
        #
        def get_layout
          Spree::Config[:layout]
        end
      end
    end
  end
end
