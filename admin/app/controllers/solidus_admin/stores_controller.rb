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
      @resource = resource_class.where(id: params[:id])

      failed = @resource.destroy_all.reject(&:destroyed?)
      if failed.none?
        flash[:notice] = t(".success")
      else
        failure_summary = failed.map { |record|
          t ".error.description",
            name: record.name,
            reason: record.errors.full_messages.join(", ")
        }.join("<br/>")

        flash[:alert] = {
          danger: {title: t(".error.title"), message: failure_summary}
        }
      end

      redirect_to after_destroy_path, status: :see_other
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
