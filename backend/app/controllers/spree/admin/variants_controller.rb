module Spree
  module Admin
    class VariantsController < ResourceController
      belongs_to 'spree/product', find_by: :slug
      new_action.before :new_before
      before_action :load_data, only: [:new, :create, :edit, :update]

      # override the destroy method to set deleted_at value
      # instead of actually deleting the product.
      def destroy
        @variant = Variant.find(params[:id])
        if @variant.destroy
          flash[:success] = Spree.t('notice_messages.variant_deleted')
        else
          flash[:success] = Spree.t('notice_messages.variant_not_deleted')
        end

        respond_with(@variant) do |format|
          format.html { redirect_to admin_product_variants_url(params[:product_id]) }
          format.js { render_js_for_destroy }
        end
      end

      private

      def new_before
        @object.attributes = @object.product.master.attributes.except('id', 'created_at', 'deleted_at',
                                                                      'sku', 'is_master')
        # Shallow Clone of the default price to populate the price field.
        @object.default_price = @object.product.master.default_price.clone
      end

      def collection
        if params[:deleted] == "on"
          base_variant_scope ||= super.with_deleted
        else
          base_variant_scope ||= super
        end

        search = Spree::Config.variant_search_class.new(params[:variant_search_term], scope: base_variant_scope)
        @collection = search.results.includes(variant_includes).page(params[:page]).per(Spree::Config[:admin_variants_per_page])
      end

      def load_data
        @tax_categories = TaxCategory.order(:name)
      end

      def variant_includes
        [{ option_values: :option_type }, :default_price]
      end
    end
  end
end
