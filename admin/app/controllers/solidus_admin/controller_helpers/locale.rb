# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Locale
  extend ActiveSupport::Concern
  include Spree::Admin::SetsUserLanguageLocaleKey

  included do
    before_action :set_locale
    before_action :update_user_locale
  end

  private

  def update_user_locale
    requested_locale = params[:switch_to_locale] or return

    if requested_locale.to_sym != user_locale
      session[set_user_language_locale_key] = requested_locale

      flash[:notice] = t('spree.locale_changed')
      redirect_to url_for(request.params.except(:switch_to_locale))
    end
  end

  def user_locale
    session[set_user_language_locale_key] || I18n.default_locale
  end

  def set_locale
    I18n.locale = user_locale
  end
end
