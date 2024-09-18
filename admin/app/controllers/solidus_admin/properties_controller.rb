# frozen_string_literal: true

module SolidusAdmin
  class PropertiesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('properties/index').new(page: @page) }
      end
    end

    def new
      @property = Spree::Property.new

      set_index_page

      respond_to do |format|
        format.html {
          render component('properties/new')
            .new(page: @page, property: @property)
        }
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

    private

    def set_index_page
      properties = apply_search_to(
        Spree::Property.order(created_at: :desc, id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(
        properties,
      )
    end
  end
end
