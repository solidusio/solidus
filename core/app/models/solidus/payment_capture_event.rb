module Spree
  class PaymentCaptureEvent < Solidus::Base
    belongs_to :payment, class_name: 'Solidus::Payment'

    def display_amount
      Solidus::Money.new(amount, { currency: payment.currency })
    end
  end
end
