# frozen_string_literal: true

require 'geared_pagination'

module SolidusAdmin
  class BaseController < ApplicationController
    include ActiveStorage::SetCurrent
    include ::SolidusAdmin::Auth
    include Spree::Core::ControllerHelpers::Store
    include Spree::Admin::SetsUserLanguageLocaleKey

    include SolidusAdmin::AuthAdapters::Backend if defined?(Spree::Backend)

    include ::GearedPagination::Controller

    before_action :set_locale

    layout 'solidus_admin/application'
    helper 'solidus_admin/container'
    helper 'solidus_admin/layout'

    private

    def set_locale
      if params[:switch_to_locale].to_s != session[set_user_language_locale_key].to_s
        session[set_user_language_locale_key] = params[:switch_to_locale]
        flash[:notice] = t('spree.locale_changed')
      end

      I18n.locale = session[set_user_language_locale_key] ? session[set_user_language_locale_key].to_sym : I18n.default_locale
    end
  end
end
