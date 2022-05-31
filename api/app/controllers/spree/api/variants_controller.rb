# frozen_string_literal: true

module Spree
  module Api
    class VariantsController < Spree::Api::BaseController
      before_action :product

      def create
        Spree::Deprecation.warn <<~MSG unless request.path.include?('/products/')
          This route is deprecated. Use the route nested within the product resource:

            POST api/products/{product_id}/variants
        MSG

        authorize! :create, Variant
        @variant = scope.new(variant_params)
        if @variant.save
          respond_with(@variant, status: 201, default_template: :show)
        else
          invalid_resource!(@variant)
        end
      end

      def destroy
        warn_if_nested_member_route

        @variant = scope.accessible_by(current_ability, :destroy).find(params[:id])
        @variant.discard
        respond_with(@variant, status: 204)
      end

      # The lazyloaded associations here are pretty much attached to which nodes
      # we render on the view so we better update it any time a node is included
      # or removed from the views.
      def index
        @variants =
          if params[:variant_search_term]
            Spree::Config.variant_search_class.new(
              params[:variant_search_term], scope: scope
            ).results.includes(include_list)
          else
            scope.includes(include_list).ransack(params[:q]).result
          end

        @variants = paginate(@variants)
        respond_with(@variants)
      end

      def new
      end

      def show
        warn_if_nested_member_route

        @variant = scope.includes(include_list)
          .find(params[:id])
        respond_with(@variant)
      end

      def update
        warn_if_nested_member_route

        @variant = scope.accessible_by(current_ability, :update).find(params[:id])
        if @variant.update(variant_params)
          respond_with(@variant, status: 200, default_template: :show)
        else
          invalid_resource!(@product)
        end
      end

      private

      def warn_if_nested_member_route
        Spree::Deprecation.warn <<~MSG if request.path.include?('/products/')
          This route is deprecated. Use shallow version instead:

            #{request.method.upcase} api/variants/:id
        MSG
      end

      def product
        @product ||= Spree::Product.accessible_by(current_ability, :show).friendly.find(params[:product_id]) if params[:product_id]
      end

      def scope
        if @product
          variants = @product.variants_including_master
        else
          variants = Spree::Variant
        end

        if current_ability.can?(:manage, Variant) && params[:show_deleted]
          variants = variants.with_discarded
        end

        in_stock_only = ActiveRecord::Type::Boolean.new.cast(params[:in_stock_only])
        suppliable_only = ActiveRecord::Type::Boolean.new.cast(params[:suppliable_only])
        variants = variants.accessible_by(current_ability)
        if in_stock_only || cannot?(:view_out_of_stock, Spree::Variant)
          variants = variants.in_stock
        elsif suppliable_only
          variants = variants.suppliable
        end
        variants
      end

      def variant_params
        params.require(:variant).permit(permitted_variant_attributes)
      end

      def include_list
        [{ option_values: :option_type }, :product, :prices, :images, { stock_items: :stock_location }]
      end
    end
  end
end
