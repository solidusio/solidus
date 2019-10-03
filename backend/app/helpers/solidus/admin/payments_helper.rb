# frozen_string_literal: true

module Solidus
  module Admin
    module PaymentsHelper
      def payment_method_name(payment)
        Solidus::Deprecation.warn "payment_method_name(payment) is deprecated. Instead use payment.payment_method.name"
        payment.payment_method.name
      end
    end
  end
end
