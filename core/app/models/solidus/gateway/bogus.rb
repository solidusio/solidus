# frozen_string_literal: true

module Solidus
  # @deprecated Use Solidus::PaymentMethod::BogusCreditCard instead
  class Gateway::Bogus < PaymentMethod::BogusCreditCard
    def initialize(*args)
      Solidus::Deprecation.warn \
        'Solidus::Gateway::Bogus is deprecated. ' \
        'Please use Solidus::PaymentMethod::BogusCreditCard instead'
      super
    end
  end
end
