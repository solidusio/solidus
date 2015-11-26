Spree::LocaleController.class_eval do
    def set
      redirect_to root_path(locale: params[:switch_to_locale])
    end
end

