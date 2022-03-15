# frozen_string_literal: true

module Spree
  module Discounts
    class Chooser
      def initialize(_discountable)
        # This signature is here to provide context in case
        # this needs to be customized
      end

      def call(discounts)
        [discounts.min_by(&:amount)].compact
      end
    end
  end
end
