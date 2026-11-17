# frozen_string_literal: true

module Spree
  # Service class responsible for helping manage the usage claims for a given
  # order.
  #
  # This class is all no-ops and exists for any store not using any promotion
  # system.
  class NullPromotionUsageLimiter
    def initialize(order)
      @order = order
    end

    # @yield The block of code to execute with the usage claims
    def claim
      yield
    end

    def release
    end

    def reclaim
    end
  end
end
