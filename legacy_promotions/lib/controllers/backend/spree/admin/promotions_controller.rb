# frozen_string_literal: true

module Spree
  module Admin
    class PromotionsController < ResourceController
      before_action :load_data

      helper "spree/promotion_rules"

      def show
        redirect_to action: :edit
      end

      def create
        @promotion = Spree::Promotion.new(permitted_resource_params)
        @promotion.codes.new(value: params[:single_code]) if params[:single_code].present?

        if params[:promotion_code_batch]
          @promotion_code_batch = @promotion.promotion_code_batches.new(promotion_code_batch_params)
        end

        if @promotion.save
          @promotion_code_batch&.process
          flash[:success] = t("spree.promotion_successfully_created")
          redirect_to location_after_save
        else
          flash[:error] = @promotion.errors.full_messages.to_sentence
          render action: "new"
        end
      end

      private

      def permitted_resource_params
        params.fetch(:promotion, {}).permit(
          :name, :description, :promotion_category_id, :usage_limit, :per_code_usage_limit,
          :starts_at, :expires_at, :apply_automatically, :path,
          promotion_rules_attributes: [
            :id, :product_ids_string, :taxon_ids_string, :user_ids_string,
            *preference_attributes(Spree::Config.promotions.rules),
            store_ids: []
          ],
          promotion_actions_attributes: [
            :id, :calculator_type,
            *preference_attributes(Spree::Config.promotions.actions),
            calculator_attributes: preference_attributes(promotion_calculators)
          ]
        )
      end

      def promotion_calculators
        Spree::Config.promotions.actions.flat_map do |action|
          Spree::Config.promotions.calculators[action].to_a
        end
      end

      # Permits the preferences declared by the given rule, action or calculator classes,
      # matching each preference's shape (array and hash preferences may hold multiple values).
      def preference_attributes(klasses)
        klasses.uniq.flat_map do |klass|
          instance = klass.new
          instance.defined_preferences.map do |name|
            attribute = :"preferred_#{name}"
            case instance.preference_type(name)
            when :array then [attribute, {attribute => []}]
            when :hash then {attribute => {}}
            else attribute
            end
          end
        end.flatten.uniq
      end

      def location_after_save
        spree.edit_admin_promotion_url(@promotion)
      end

      def load_data
        @promotion_categories = Spree::PromotionCategory.order(:name)
      end

      def collection
        return @collection if @collection
        params[:q] ||= HashWithIndifferentAccess.new
        params[:q][:s] ||= "id desc"

        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result(distinct: true)
          .includes(promotion_includes)
          .page(params[:page])
          .per(params[:per_page] || Spree::Config.promotions.promotions_per_page)

        @collection
      end

      def promotion_code_batch_params
        params.require(:promotion_code_batch).permit(:base_code, :number_of_codes, :join_characters, :email)
      end

      def promotion_includes
        [:promotion_actions]
      end
    end
  end
end
