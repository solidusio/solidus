# frozen_string_literal: true

module SolidusAdmin
  class StoresController < SolidusAdmin::ResourcesController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      stores = apply_search_to(
        Spree::Store.order(id: :desc),
        param: :q
      )

      set_page_and_extract_portion_from(stores)

      respond_to do |format|
        format.html { render component("stores/index").new(page: @page) }
      end
    end

    def destroy
      @stores = Spree::Store.where(id: params[:id])

      Spree::Store.transaction { @stores.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to stores_path, status: :see_other
    end

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
