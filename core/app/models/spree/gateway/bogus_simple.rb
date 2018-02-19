# frozen_string_literal: true

module Spree
  # @deprecated Use Spree::PaymentMethod::SimpleBogusCreditCard instead
  class Gateway::BogusSimple < Spree::PaymentMethod::SimpleBogusCreditCard
    def initialize(*args)
      Spree::Deprecation.warn \
        'Spree::Gateway::BogusSimple is deprecated. ' \
        'Please use Spree::PaymentMethod::SimpleBogusCreditCard instead'
      super
    end
  end
end
