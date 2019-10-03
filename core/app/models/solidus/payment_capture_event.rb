# frozen_string_literal: true

module Solidus
  class PaymentCaptureEvent < Solidus::Base
    belongs_to :payment, class_name: 'Solidus::Payment', optional: true

    def display_amount
      Solidus::Money.new(amount, { currency: payment.currency })
    end
  end
end
