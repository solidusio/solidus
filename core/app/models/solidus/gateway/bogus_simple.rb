# frozen_string_literal: true

module Solidus
  # @deprecated Use Solidus::PaymentMethod::SimpleBogusCreditCard instead
  class Gateway::BogusSimple < Solidus::PaymentMethod::SimpleBogusCreditCard
    def initialize(*args)
      Solidus::Deprecation.warn \
        'Solidus::Gateway::BogusSimple is deprecated. ' \
        'Please use Solidus::PaymentMethod::SimpleBogusCreditCard instead'
      super
    end
  end
end
