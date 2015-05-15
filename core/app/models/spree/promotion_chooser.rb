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
        other_promotions = @adjustments.where.not(id: best_promotion_adjustment.id)
        other_promotions.update_all(:eligible => false)
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
