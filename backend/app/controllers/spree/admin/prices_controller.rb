module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def index
        params[:q] ||= {}

        @search = @product.prices.accessible_by(current_ability, :index).ransack(params[:q])
        @prices = @search.result
          .currently_valid
          .order(:variant_id, :country_iso, :currency)
          .page(params[:page]).per(Spree::Config.admin_variants_per_page)
      end

      def edit
      end
    end
  end
end
