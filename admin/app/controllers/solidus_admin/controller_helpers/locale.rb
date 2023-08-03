# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Locale
  extend ActiveSupport::Concern
  include Spree::Admin::SetsUserLanguageLocaleKey

  included do
    before_action :set_locale
  end

  private

  def set_locale
    if params[:switch_to_locale].to_s != session[set_user_language_locale_key].to_s
      session[set_user_language_locale_key] = params[:switch_to_locale]
      flash[:notice] = t('spree.locale_changed')
    end

    I18n.locale = session[set_user_language_locale_key] ? session[set_user_language_locale_key].to_sym : I18n.default_locale
  end
end
