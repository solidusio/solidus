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
          adjustment.update_columns(eligible: false)
        end
        best_promotion_adjustment.amount
      else
        BigDecimal.new('0')
      end
    end

    private

    # @return The best promotion from this set of adjustments.
    def best_promotion_adjustment
      @best_promotion_adjustment ||= @adjustments.select(&:eligible?).min_by do |a|
        [a.amount, -a.id]
      end
    end
  end
end
