# frozen_string_literal: true

module Spree
  module Api
    class StockItemsController < Spree::Api::BaseController
      before_action :load_stock_location, only: [:index, :show, :create]

      rescue_from Spree::StockLocation::InvalidMovementError, with: :render_stock_items_error

      def index
        @stock_items = paginate(scope.ransack(params[:q]).result)
        respond_with(@stock_items)
      end

      def show
        @stock_item = scope.find(params[:id])
        respond_with(@stock_item)
      end

      def create
        authorize! :create, StockItem
        @stock_item = scope.new(stock_item_params)

        Spree::StockItem.transaction do
          if @stock_item.save
            adjust_stock_item_count_on_hand(count_on_hand_adjustment)
            respond_with(@stock_item, status: 201, default_template: :show)
          else
            invalid_resource!(@stock_item)
          end
        end
      end

      def update
        @stock_item = Spree::StockItem.accessible_by(current_ability, :update).find(params[:id])
        @stock_location = @stock_item.stock_location

        adjustment = count_on_hand_adjustment
        params[:stock_item].delete(:count_on_hand)
        adjustment -= @stock_item.count_on_hand if params[:stock_item][:force]

        Spree::StockItem.transaction do
          if @stock_item.update(stock_item_params)
            adjust_stock_item_count_on_hand(adjustment)
            respond_with(@stock_item, status: 200, default_template: :show)
          else
            invalid_resource!(@stock_item)
          end
        end
      end

      def destroy
        @stock_item = Spree::StockItem.accessible_by(current_ability, :destroy).find(params[:id])
        @stock_item.discard
        respond_with(@stock_item, status: 204)
      end

      private

      def load_stock_location
        @stock_location ||= Spree::StockLocation.accessible_by(current_ability).find(params.fetch(:stock_location_id))
      end

      def scope
        includes = { variant: [{ option_values: :option_type }, :product] }
        @stock_location.stock_items.accessible_by(current_ability, :read).includes(includes)
      end

      def stock_item_params
        params.require(:stock_item).delete(:force)
        params.require(:stock_item).permit(permitted_stock_item_attributes)
      end

      def count_on_hand_adjustment
        params[:stock_item][:count_on_hand].to_i
      end

      def adjust_stock_item_count_on_hand(count_on_hand_adjustment)
        if @stock_item.count_on_hand + count_on_hand_adjustment < 0
          raise StockLocation::InvalidMovementError.new(t('spree.api.stock_not_below_zero'))
        end
        @stock_movement = @stock_location.move(@stock_item.variant, count_on_hand_adjustment, current_api_user)
        @stock_item = @stock_movement.stock_item
      end

      def render_stock_items_error
        render json: { error: t('spree.api.stock_not_below_zero') }, status: 422
      end
    end
  end
end
