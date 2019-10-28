# frozen_string_literal: true

module Spree
  class PromotionChooser
    def initialize(adjustments)
      @adjustments = adjustments
    end

    # Picks the best promotion from this set of adjustments, all others are
    # marked as ineligible.
    #
    # @return [BigDecimal] The amount of the best adjustment
    def update
      if best_promotion_adjustment
        @adjustments.select(&:eligible?).each do |adjustment|
          next if adjustment == best_promotion_adjustment
          adjustment.update_columns(eligible: false, updated_at: Time.current)
        end
        best_promotion_adjustment.amount
      else
        BigDecimal('0')
      end
    end

    private

    # @return The best promotion from this set of adjustments.
    def best_promotion_adjustment
      @best_promotion_adjustment ||= @adjustments.select(&:eligible?).min_by do |adjustment|
        [adjustment.amount, -adjustment.id]
      end
    end
  end
end
