module Spree
  module Admin
    class VariantImageRulesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      create.fails  :load_data
      update.fails  :load_data
      before_action :load_data, only: [:index]
      before_action :split_option_value_params, only: [:create, :update]

      private
        def load_data
          @product = Product.friendly.find(params[:product_id])
          @product.product_properties.build
          @option_types = @product.variant_option_values_by_option_type
          @option_value_ids = (params[:ovi] || []).reject(&:blank?).map(&:to_i)
          @variant_image_rule = @product.find_variant_image_rule(@option_value_ids) || @product.variant_image_rules.build
        end

        def split_option_value_params
          params[:option_value_ids] = params[:variant_image_rule][:option_value_ids].split(',')
        end

        def location_after_save
          spree.admin_product_variant_image_rules_url(@product, { ovi: params[:option_value_ids] })
        end

        def render_index
          render action: 'index'
        end
        alias_method :render_after_create_error, :render_index
        alias_method :render_after_update_error, :render_index
    end
  end
end
