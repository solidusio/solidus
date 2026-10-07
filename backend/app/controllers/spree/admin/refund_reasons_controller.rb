# frozen_string_literal: true

module Spree
  module Admin
    class RefundReasonsController < ResourceController
      private

      def permitted_resource_params
        params.require(:refund_reason).permit(:name, :code, :active)
      end
    end
  end
end
