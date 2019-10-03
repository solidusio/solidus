# frozen_string_literal: true

module Solidus
  # @deprecated Use Solidus::PaymentMethod::CreditCard or Solidus::PaymentMethod instead
  class Gateway < PaymentMethod::CreditCard
    def initialize(*args)
      Solidus::Deprecation.warn \
        "Using Solidus::Gateway as parent class of payment methods is deprecated. " \
        "Please use Solidus::PaymentMethod::CreditCard for credit card based payment methods " \
        "or Solidus::PaymentMethod for non credit card payment methods instead."
      super
    end
  end
end
