# frozen_string_literal: true

module Spree
  module Api
    class InventoryUnitsController < Spree::Api::BaseController
      before_action :prepare_event, only: :update

      def show
        @inventory_unit = inventory_unit
        respond_with(@inventory_unit)
      end

      def update
        authorize! :update, inventory_unit.order

        inventory_unit.transaction do
          if inventory_unit.update(inventory_unit_params)
            fire
            render :show, status: :ok
          else
            invalid_resource!(inventory_unit)
          end
        end
      end

      private

      def inventory_unit
        @inventory_unit ||= Spree::InventoryUnit.accessible_by(current_ability, :show).find(params[:id])
      end

      def prepare_event
        @event = params[:fire]
        return unless @event

        can_event = "can_#{@event}?"

        unless inventory_unit.respond_to?(can_event) && inventory_unit.send(can_event)
          render json: {exception: "cannot transition to #{@event}"}, status: :ok
          false
        end
      end

      def fire
        inventory_unit.send(:"#{@event}!") if @event
      end

      def inventory_unit_params
        params.require(:inventory_unit).permit(permitted_inventory_unit_attributes)
      end
    end
  end
end
