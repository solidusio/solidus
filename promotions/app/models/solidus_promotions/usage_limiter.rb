# frozen_string_literal: true

module SolidusPromotions
  # Service class responsible for helping manage the usage claims for a given
  # order.
  class UsageLimiter
    attr_reader :order

    def initialize(order)
      @order = order
    end

    # Wraps a block of code that should be executed with the usage claims for
    # the order. This is meant to wrap the transition to complete.
    #
    # It will attempt to claim the usage for all of the limited promotions and
    # promotion codes on the order. If any of them cannot be claimed, it will
    # add an error to the order and not yield to the block.
    #
    # If the block is yielded to, it is expected that the order will be
    # completed. If the order is not completed for any reason, the usage claims
    # will be released.
    #
    # @yield The block of code to execute with the usage claims
    def claim
      records = limited_records
      claimed = records.take_while(&:claim_usage)
      completed = false

      if claimed.size < records.size
        order.errors.add(:base, I18n.t("solidus_promotions.usage_limit_reached_before_complete"))
      else
        order.promotion_usage_claims = claimed
        yield
        completed = true
      end
    ensure
      order.promotion_usage_claims = nil
      claimed&.each(&:release_usage) unless completed
    end

    # Releases the usage claims for the order. This is meant to be called if the
    # order is canceled.
    def release
      limited_records.each(&:release_usage)
    end

    # Reclaims the usage claims for the order. This is meant to be called when
    # an order is resumed from a cancelled state.
    #
    # We ignore usage limits here because that's how the existing logic worked.
    def reclaim
      limited_records.each { |record| record.claim_usage(enforce_limit: false) }
    end

    private

    def limited_records
      # Automatic promotions aren't connected to the order through order
      # promotions, so also look for them through the order's adjustments.
      benefit_ids = order.all_adjustments.where(source_type: SolidusPromotions::Benefit.name).select(:source_id)
      promotions = SolidusPromotions::Promotion
        .where(id: order.solidus_order_promotions.select(:promotion_id))
        .or(SolidusPromotions::Promotion.where(id: SolidusPromotions::Benefit.where(id: benefit_ids).select(:promotion_id)))
        .where.not(usage_limit: nil)
      codes = SolidusPromotions::PromotionCode
        .where(id: order.solidus_order_promotions.select(:promotion_code_id))
        .joins(:promotion)
        .where.not(SolidusPromotions::Promotion.table_name => {per_code_usage_limit: nil})

      promotions.to_a + codes.to_a
    end
  end
end
