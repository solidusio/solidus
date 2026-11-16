# frozen_string_literal: true

module SolidusAdmin
  class StockMovementsController < SolidusAdmin::ResourcesController
    before_action :set_stock_location

    def index
      respond_to do |format|
        format.html do
          render component("stock_movements/index").new(page: @page, stock_location: @stock_location)
        end
      end
    end

    private

    def resource_class = Spree::StockMovement

    def set_stock_location
      @stock_location = Spree::StockLocation
        .accessible_by(current_ability)
        .find(params[:stock_location_id])
    end

    def resources_collection
      set_stock_location
        .stock_movements
        .includes(:originator, stock_item: {variant: [:product, {option_values: :option_type}]})
    end

    # Most recent movements first, like the legacy backend page.
    def resources_sorting_options
      {created_at: :desc, id: :desc}
    end
  end
end
