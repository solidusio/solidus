# frozen_string_literal: true

module SolidusAdmin
  class StockLocationsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      stock_locations = apply_search_to(
        Spree::StockLocation.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(stock_locations)

      respond_to do |format|
        format.html { render component('stock_locations/index').new(page: @page) }
      end
    end

    def destroy
      @stock_locations = Spree::StockLocation.where(id: params[:id])

      Spree::StockLocation.transaction { @stock_locations.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to stock_locations_path, status: :see_other
    end

    private

    def stock_location_params
      params.require(:stock_location).permit(:stock_location_id, permitted_stock_location_attributes)
    end
  end
end
