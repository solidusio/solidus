# frozen_string_literal: true

module Spree
  # @deprecated Use Spree::PaymentMethod::BogusCreditCard instead
  class Gateway::Bogus < PaymentMethod::BogusCreditCard
    def initialize(*args)
      Spree::Deprecation.warn \
        'Spree::Gateway::Bogus is deprecated. ' \
        'Please use Spree::PaymentMethod::BogusCreditCard instead'
      super
    end
  end
end
