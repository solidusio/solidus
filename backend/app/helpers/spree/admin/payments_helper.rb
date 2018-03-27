# frozen_string_literal: true

module Spree
  module Admin
    module PaymentsHelper
      def payment_method_name(payment)
        payment.payment_method.name
      end
    end
  end
end
