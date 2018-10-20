# frozen_string_literal: true

module Spree
  module Admin
    module PaymentsHelper
      def payment_method_name(payment)
        Spree::Deprecation.warn "payment_method_name(payment) is deprecated. Instead use payment.payment_method.name"
        payment.payment_method.name
      end
    end
  end
end
