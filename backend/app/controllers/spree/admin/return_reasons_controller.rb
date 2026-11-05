# frozen_string_literal: true

module Spree
  module Admin
    class ReturnReasonsController < ResourceController
      private

      def permitted_resource_params
        params.require(:return_reason).permit(:name, :active)
      end
    end
  end
end
