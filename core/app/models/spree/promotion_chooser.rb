module Spree
  # I Choo-Choo-Choose You
  class PromotionChooser
    # FIXME: adjust currently needs to be a scope
    def initialize(adjustments)
      @adjustments = adjustments
    end

    # Picks one (and only one) promotion to be eligible for this order
    # This promotion provides the most discount, and if two promotions
    # have the same amount, then it will pick the latest one.
    def update
      if best_promotion_adjustment
        @adjustments.select(&:eligible?).each do |adjustment|
          next if adjustment == best_promotion_adjustment
          adjustment.update_columns(eligible: false)
        end
        best_promotion_adjustment.amount
      else
        0
      end
    end

    def best_promotion_adjustment
      @best_promotion_adjustment ||= @adjustments.eligible.reorder("amount ASC, created_at DESC, id DESC").first
    end
  end
end
