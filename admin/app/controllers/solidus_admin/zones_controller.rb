# frozen_string_literal: true

module SolidusAdmin
  class ZonesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      zones = apply_search_to(
        Spree::Zone.order(id: :desc),
        param: :q
      )

      set_page_and_extract_portion_from(zones)

      respond_to do |format|
        format.html { render component('zones/index').new(page: @page) }
      end
    end

    def destroy
      @zones = Spree::Zone.where(id: params[:id])

      Spree::Zone.transaction { @zones.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to zones_path, status: :see_other
    end

    private

    def load_zone
      @zone = Spree::Zone.find_by!(number: params[:id])
      authorize! action_name, @zone
    end

    def zone_params
      params.require(:zone).permit(:zone_id, permitted_zone_attributes)
    end
  end
end
