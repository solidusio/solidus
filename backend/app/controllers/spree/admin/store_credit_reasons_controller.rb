# frozen_string_literal: true

module Spree
  module Admin
    class StoreCreditReasonsController < ResourceController
      private

      def permitted_resource_params
        params.require(:store_credit_reason).permit(:name, :active)
      end
    end
  end
end
