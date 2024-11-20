# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeAdjustmentDecorator
    def self.prepended(base)
      base.belongs_to :promotion_code, class_name: 'Spree::PromotionCode', optional: true
      base.validates :promotion_code, presence: true, if: :require_promotion_code?

      base.scope :eligible, -> { where(eligible: true) }
    end

    # Recalculate and persist the amount from this adjustment's source based on
    # the adjustable ({Order}, {Shipment}, or {LineItem})
    #
    # If the adjustment has no source (such as when created manually from the
    # admin) or is closed, this is a noop.
    #
    # @return [BigDecimal] New amount of this adjustment
    def recalculate
      if finalized? && !tax?
        return amount
      end

      # If the adjustment has no source, do not attempt to re-calculate the
      # amount.
      # Some scenarios where this happens:
      #   - Adjustments that are manually created via the admin backend
      #   - PromotionAction adjustments where the PromotionAction was deleted
      #     after the order was completed.
      if source.present?
        self.amount = source.compute_amount(adjustable)

        if promotion?
          self.eligible = calculate_eligibility
        end

        # Persist only if changed
        # This is only not a save! to avoid the extra queries to load the order
        # (for validations) and to touch the adjustment.
        update_columns(eligible:, amount:, updated_at: Time.current) if changed?
      end
      amount
    end
    deprecate :recalculate, deprecator: Spree.deprecator

    # Calculates based on attached promotion (if this is a promotion
    # adjustment) whether this promotion is still eligible.
    # @api private
    # @return [true,false] Whether this adjustment is eligible
    def calculate_eligibility
      if !finalized? && source && promotion?
        source.promotion.eligible?(adjustable, promotion_code:)
      else
        eligible?
      end
    end
    deprecate :calculate_eligibility, deprecator: ::Spree.deprecator

    def eligible
      self[:eligible]
    end
    alias_method :eligible?, :eligible

    private

    def legacy_promotion?
      source_type == "Spree::PromotionAction"
    end

    def require_promotion_code?
      legacy_promotion? && !source.promotion.apply_automatically && source.promotion.codes.any?
    end

    Spree::Adjustment.prepend self
  end
end
