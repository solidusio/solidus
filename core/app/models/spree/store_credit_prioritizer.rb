# frozen_string_literal: true

module Spree
  class StoreCreditPrioritizer
    def initialize(credits, _order)
      @credits = credits
    end

    def call
      credits.order_by_priority
    end

    private

    attr_reader :credits
  end
end

