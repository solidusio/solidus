# frozen_string_literal: true

module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      before_action :set_breadcrumbs

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

      private

      def set_breadcrumbs
        set_product_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Price), spree.admin_product_prices_url(@product)
        add_breadcrumb t('spree.actions.edit') if action_name == 'edit'
        add_breadcrumb t('spree.actions.new')  if action_name == 'new'
      end
    end
  end
end
