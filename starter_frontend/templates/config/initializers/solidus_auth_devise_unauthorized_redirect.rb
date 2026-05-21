Rails.application.config.to_prepare do
  Spree::BaseController.unauthorized_redirect = -> do
    if spree_current_user
      flash[:error] = I18n.t('spree.authorization_failure')

      if Spree::Auth::Engine.redirect_back_on_unauthorized?
        redirect_back(fallback_location: unauthorized_path)
      else
        redirect_to unauthorized_path
      end
    else
      store_location

      if Spree::Auth::Engine.redirect_back_on_unauthorized?
        redirect_back(fallback_location: login_path)
      else
        redirect_to login_path
      end
    end
  end
end
