# frozen_string_literal: true

module Spree
  # @deprecated Use Spree::PaymentMethod::CreditCard or Spree::PaymentMethod instead
  class Gateway < PaymentMethod::CreditCard
    def initialize(*args)
      Spree::Deprecation.warn \
        "Using Spree::Gateway as parent class of payment methods is deprecated. " \
        "Please use Spree::PaymentMethod::CreditCard for credit card based payment methods " \
        "or Spree::PaymentMethod for non credit card payment methods instead."
      super
    end
  end
end
