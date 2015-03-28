module Spree
  class LocaleController < Spree::StoreController
    def set
      redirect_to root_path(locale: params[:switch_to_locale])
    end
  end
end
