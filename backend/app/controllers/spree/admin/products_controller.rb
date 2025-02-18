# frozen_string_literal: true

module Spree
  module Admin
    class ProductsController < ResourceController
      helper "spree/products"

      before_action :load_data, except: [:index]
      update.before :update_before
      helper_method :clone_object_url
      before_action :split_params, only: [:create, :update]
      before_action :normalize_variant_property_rules, only: [:update]
      before_action :set_default_tax_category, only: [:new, :edit]

      def show
        redirect_to action: :edit
      end

      def index
        session[:return_to] = request.url
        respond_with(@collection)
      end

      def destroy
        @product = Spree::Product.friendly.find(params[:id])
        @product.discard

        flash[:success] = t("spree.notice_messages.product_deleted")

        respond_with(@product) do |format|
          format.html { redirect_to collection_url }
          format.js { render_js_for_destroy }
        end
      end

      def clone
        @new = @product.duplicate

        if @new.save
          flash[:success] = t("spree.notice_messages.product_cloned")
        else
          flash[:error] = t("spree.notice_messages.product_not_cloned")
        end

        redirect_to edit_admin_product_url(@new)
      end

      private

      def set_default_tax_category
        @product.tax_category_id ||= @default_tax_category&.id
      end

      def split_params
        if params[:product][:taxon_ids].present?
          params[:product][:taxon_ids] = params[:product][:taxon_ids].split(",")
        end
        if params[:product][:option_type_ids].present?
          params[:product][:option_type_ids] = params[:product][:option_type_ids].split(",")
        end
      end

      def find_resource
        Spree::Product.with_discarded.friendly.find(params[:id])
      end

      def location_after_save
        if updating_variant_property_rules?
          url_params = {}
          url_params[:ovi] = []
          params[:product][:variant_property_rules_attributes].each_value do |param_attrs|
            url_params[:ovi] += param_attrs[:option_value_ids]
          end
          spree.admin_product_product_properties_url(@product, url_params)
        else
          spree.edit_admin_product_url(@product)
        end
      end

      def load_data
        @tax_categories = Spree::TaxCategory.order(:name)
        @default_tax_category = @tax_categories.detect(&:is_default)
        @shipping_categories = Spree::ShippingCategory.order(:name)
      end

      def collection
        return @collection if @collection
        params[:q] ||= {}
        params[:q][:s] ||= "name asc"
        # @search needs to be defined as this is passed to search_form_for
        @search = super.ransack(params[:q])
        @collection = @search.result
          .order(id: :asc)
          .includes(product_includes)
          .page(params[:page])
          .per(Spree::Config[:admin_products_per_page])
      end

      def update_before
        # note: we only reset the product properties if we're receiving a post
        #       from the form on that tab
        return unless params[:clear_product_properties]
        params[:product] ||= {}
      end

      def product_includes
        [:variant_images, {variants: [:images], master: [:images, :prices]}]
      end

      def clone_object_url(resource)
        clone_admin_product_url resource
      end

      def variant_stock_includes
        [:images, stock_items: :stock_location, option_values: :option_type]
      end

      def variant_scope
        @product.variants
      end

      def updating_variant_property_rules?
        params[:product][:variant_property_rules_attributes].present?
      end

      def render_after_update_error
        # Stops people submitting blank slugs, causing errors when they try to
        # update the product again
        @product.slug = @product.slug_was if @product.slug.blank?
        render action: "edit"
      end

      def normalize_variant_property_rules
        return unless updating_variant_property_rules?

        params[:product][:variant_property_rules_attributes].each_value do |param_attrs|
          param_attrs[:option_value_ids] = param_attrs[:option_value_ids].split(",")
        end
      end
    end
  end
end
