# frozen_string_literal: true

module Spree
  module Admin
    class VariantsController < ResourceController
      helper 'spree/admin/products'

      belongs_to 'spree/product', find_by: :slug
      new_action.before :new_before
      before_action :redirect_on_empty_option_values, only: [:new]
      before_action :load_data, only: [:new, :create, :edit, :update]

      private

      def new_before
        @object.attributes = @object.product.master.attributes.except('id', 'created_at', 'deleted_at',
                                                                      'sku', 'is_master')
        # Shallow Clone of the default price to populate the price field.
        @object.default_price = @object.product.master.default_price.clone
      end

      def collection
        if params[:deleted] == "on"
          base_variant_scope ||= super.with_discarded
        else
          base_variant_scope ||= super
        end

        search = Spree::Config.variant_search_class.new(params[:variant_search_term], scope: base_variant_scope)
        @collection = search.results.includes(variant_includes).page(params[:page]).per(Spree::Config[:admin_variants_per_page])
      end

      def load_data
        @tax_categories = Spree::TaxCategory.order(:name)
      end

      def variant_includes
        [{ option_values: :option_type }, :default_price]
      end

      def redirect_on_empty_option_values
        redirect_to admin_product_variants_url(params[:product_id]) if @product.empty_option_values?
      end

      def parent
        @parent ||= Spree::Product.with_discarded.find_by(slug: params[:product_id])
        @product = @parent
      end
    end
  end
end
