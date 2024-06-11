# frozen_string_literal: true

module SolidusAdmin
  class PropertiesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      properties = apply_search_to(
        Spree::Property.order(created_at: :desc, id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(
        properties,
      )

      respond_to do |format|
        format.html { render component('properties/index').new(page: @page) }
      end
    end

    def destroy
      @properties = Spree::Property.where(id: params[:id])

      Spree::Property.transaction do
        @properties.destroy_all
      end

      flash[:notice] = t('.success')
      redirect_to properties_path, status: :see_other
    end
  end
end
