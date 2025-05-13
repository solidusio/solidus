# frozen_string_literal: true

module SolidusAdmin
  class StoresController < SolidusAdmin::ResourcesController
    def destroy
      @resource = resource_class.where(id: params[:id])

      failed = @resource.destroy_all.reject(&:destroyed?)
      if failed.present?
        desc = failed.map { t(".error.description", name: _1.name, reason: _1.errors.full_messages.join(" ")) }.join("<br>")
        flash[:alert] = { danger: { title: t(".error.title"), description: desc } }
      else
        flash[:notice] = t('.success')
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
