# frozen_string_literal: true

module Spree
  class LocaleController < Spree::StoreController
    def set
      if params[:locale] && I18n.available_locales.map(&:to_s).include?(params[:locale])
        session[:locale] = I18n.locale = params[:locale]
        flash.notice = t('spree.locale_changed')
      else
        flash[:error] = t('spree.locale_not_changed')
      end
      redirect_back_or_default(spree.root_path)
    end
  end
end
