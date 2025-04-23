# frozen_string_literal: true

module SolidusAdmin
  class StoresController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::Store

    def resources_collection = Spree::Store

    def permitted_resource_params
      params.require(:store).permit(
        :name,
        :url,
        :code,
        :meta_description,
        :meta_keywords,
        :seo_title,
        :mail_from_address,
        :default_currency,
        :cart_tax_country_iso,
        available_locales: [],
      )
    end
  end
end
