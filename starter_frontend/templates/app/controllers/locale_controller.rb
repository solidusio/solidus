# frozen_string_literal: true

class LocaleController < StoreController
  def set
    requested_locale = params[:switch_to_locale] || params[:locale]

    if locale_is_available?(requested_locale)
      I18n.locale = requested_locale
      session[set_user_language_locale_key] = requested_locale
      flash.notice = t('spree.locale_changed')
    else
      flash[:error] = t('spree.locale_not_changed')
    end

    redirect_to root_path
  end

  private

  def locale_is_available?(locale)
    locale && Spree.i18n_available_locales.include?(locale.to_sym)
  end
end
