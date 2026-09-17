# frozen_string_literal: true

module Spree
  class PaymentMethod::Check < PaymentMethod
    def actions
      %w[capture void credit]
    end

    def can_capture?(payment)
      ["checkout", "pending"].include?(payment.state)
    end

    def can_void?(payment)
      payment.state != "void"
    end

    def can_credit?(payment)
      payment.completed? && payment.credit_allowed > 0
    end

    def capture(*)
      simulated_successful_billing_response
    end

    def void(*)
      simulated_successful_billing_response
    end
    alias_method :try_void, :void

    def credit(*)
      simulated_successful_billing_response
    end

    def source_required?
      false
    end

    def simulated_successful_billing_response
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end
  end
end
