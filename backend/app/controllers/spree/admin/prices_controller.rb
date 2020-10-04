# frozen_string_literal: true

module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def index
        params[:q] ||= {}

        @search = @product.prices.accessible_by(current_ability, :index).ransack(params[:q])
        @master_prices = @search.result
          .currently_valid
          .for_master
          .order(:variant_id, :country_iso, :currency)
          .page(params[:page]).per(Spree::Config.admin_variants_per_page)
        @variant_prices = @search.result
          .currently_valid
          .for_variant
          .order(:variant_id, :country_iso, :currency)
          .page(params[:page]).per(Spree::Config.admin_variants_per_page)
      end

      def edit
      end
    end
  end
end
