# frozen_string_literal: true

module Spree
  # Service class responsible for helping manage the usage claims for a given
  # order.
  class PromotionUsageLimiter
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
        order.errors.add(:base, I18n.t("spree.promotion_usage_limit_reached_before_complete"))
      else
        yield
        completed = true
      end
    ensure
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
      promotions = Spree::Promotion
        .where(id: order.order_promotions.select(:promotion_id))
        .where.not(usage_limit: nil)
      codes = Spree::PromotionCode
        .where(id: order.order_promotions.select(:promotion_code_id))
        .joins(:promotion)
        .where.not(spree_promotions: {per_code_usage_limit: nil})

      promotions.to_a + codes.to_a
    end
  end
end
