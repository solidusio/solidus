# frozen_string_literal: true

module Spree
  class NullPromotionAdjuster
    def initialize(order)
      @order = order
    end

    def call
      @order
    end
  end
end
