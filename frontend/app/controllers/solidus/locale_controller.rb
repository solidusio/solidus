module Solidus
  class LocaleController < Solidus::StoreController
    def set
      if request.referer && request.referer.starts_with?('http://' + request.host)
        session['user_return_to'] = request.referer
      end
      if params[:locale] && I18n.available_locales.map(&:to_s).include?(params[:locale])
        session[:locale] = I18n.locale = params[:locale]
        flash.notice = Solidus.t(:locale_changed)
      else
        flash[:error] = Solidus.t(:locale_not_changed)
      end
      redirect_back_or_default(solidus.root_path)
    end
  end
end
