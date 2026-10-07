# frozen_string_literal: true

module Spree
  module Admin
    class AdjustmentReasonsController < ResourceController
      private

      def permitted_resource_params
        params.require(:adjustment_reason).permit(:name, :code, :active)
      end
    end
  end
end
