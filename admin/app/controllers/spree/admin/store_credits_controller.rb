module Spree
  module Admin
    class StoreCreditsController < ResourceController
      belongs_to 'spree/user', model_class: Spree.user_class
      before_action :load_categories, only: [:new, :edit]
      create.fails :load_categories
      update.fails :load_categories
      create.before :set_action_originator

      def invalidate
        if @store_credit.invalidate
          respond_with(@store_credit) do |format|
            format.html { redirect_to location_after_destroy }
            format.js   { render :partial => "spree/admin/shared/destroy" }
          end
        else
          respond_with(@store_credit) do |format|
            format.html { redirect_to location_after_destroy }
          end
        end
      end

      private

      def permitted_resource_params
        params.require(:store_credit).permit([:amount, :category_id, :memo]).
          merge(currency: Spree::Config[:currency], created_by: try_spree_current_user)
      end

      def collection
        @collection = super.reverse_order
      end

      def load_categories
        @credit_categories = Spree::StoreCreditCategory.all.order(:name)
      end

      def set_action_originator
        @object.action_originator = try_spree_current_user
      end
    end
  end
end
