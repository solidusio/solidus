module Spree
  module Admin
    class PromotionsController < ResourceController
      before_action :load_data
      before_action :load_bulk_code_information, only: [:edit]

      create.before :build_promotion_codes

      helper 'spree/promotion_rules'

      def create
        @promotion_builder = Spree::PromotionBuilder.new(
          permitted_promo_builder_params.merge(user: try_spree_current_user),
          permitted_resource_params
        )
        @promotion = @promotion_builder.promotion

        if @promotion_builder.perform
          flash[:success] = Spree.t(:promotion_successfully_created)
          redirect_to location_after_save
        else
          flash[:error] = @promotion_builder.errors.full_messages.join(", ")
          render action: 'new'
        end
      end

      private

      def load_bulk_code_information
        @promotion_builder = Spree::PromotionBuilder.new(
          base_code: @promotion.codes.first.try!(:value),
          number_of_codes: @promotion.codes.count
        )
      end

      def location_after_save
        spree.edit_admin_promotion_url(@promotion)
      end

      def load_data
        @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
        @promotion_categories = Spree::PromotionCategory.order(:name)
      end

      def collection
        return @collection if defined?(@collection)
        params[:q] ||= HashWithIndifferentAccess.new
        params[:q][:s] ||= 'id desc'

        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result(distinct: true).
          includes(promotion_includes).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:promotions_per_page])

        @collection
      end

      def promotion_includes
        [:promotion_actions]
      end

      def permitted_promo_builder_params
        if params[:promotion_builder]
          params[:promotion_builder].permit(:base_code, :number_of_codes)
        else
          {}
        end
      end
    end
  end
end
