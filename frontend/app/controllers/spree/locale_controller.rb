# frozen_string_literal: true

module Spree
  class LocaleController < Spree::StoreController
    def set
      available_locales = Spree.i18n_available_locales
      requested_locale = params[:switch_to_locale] || params[:locale]

      if requested_locale && available_locales.map(&:to_s).include?(requested_locale)
        session[set_user_language_locale_key] = requested_locale
        I18n.locale = requested_locale
        flash.notice = t('spree.locale_changed')
      else
        flash[:error] = t('spree.locale_not_changed')
      end

      redirect_to spree.root_path
    end
  end
end
