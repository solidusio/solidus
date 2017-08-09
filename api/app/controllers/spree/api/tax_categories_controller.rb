module Spree
  module Api
    class TaxCategoriesController < Spree::Api::BaseController
      skip_before_action :authenticate_user

      def update
        @tax_category = Spree::TaxCategory.
          accessible_by(current_ability, :update).
          find(params[:id])

        if @tax_category.update_attributes(tax_category_params)
          respond_with(@tax_category, default_template: :show)
        else
          invalid_resource!(@tax_category)
        end
      end

      private

      def tax_category_params
        params.require(:tax_category).permit(permitted_tax_category_attributes)
      end
    end
  end
end
