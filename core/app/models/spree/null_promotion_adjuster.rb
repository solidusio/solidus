# frozen_string_literal: true

module Spree
  class NullPromotionAdjuster
    def initialize(order)
      @order = order
    end

    def call(persist: true) # rubocop:disable Lint/UnusedMethodArgument
      @order
    end
  end
end
