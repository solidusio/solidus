# frozen_string_literal: true

module Spree
  # Tracks the uses of a usage limited promotion or promotion code in a
  # counter that is updated atomically, so that concurrent checkouts can't
  # exceed the usage limit.
  #
  # Including models need an integer `usage_claims_count` column and must
  # respond to `usage_limit` and `usage_count_from_orders`.
  module PromotionUsageClaims
    # Claims a use, unless the usage limit has been reached. We use an atomic
    # update to avoid race conditions when multiple checkouts are trying to
    # claim the last use of a promotion at the same time.
    #
    # @param enforce_limit [Boolean] whether to refuse the claim when the
    #   usage limit has been reached
    # @return [Boolean] whether the use was claimed
    def claim_usage(enforce_limit: true)
      claims = self.class.where(id:)
      if enforce_limit && usage_limit
        claims = claims.where(self.class.arel_table[:usage_claims_count].lt(usage_limit))
      end
      claims.update_all("usage_claims_count = usage_claims_count + 1") == 1
    end

    # Releases a previously claimed use. Once again, we use update_all so that
    # the call is atomic with the condition that the usage claims count is
    # greater than zero, so that we don't accidentally make the count negative
    # if the release is called more times than the claim.
    def release_usage
      self.class
        .where(id:)
        .where(self.class.arel_table[:usage_claims_count].gt(0))
        .update_all("usage_claims_count = usage_claims_count - 1")
    end

    # Resets the claims counter from the recorded usage, e.g. to correct drift
    def recalculate_usage_claims_count
      update_column(:usage_claims_count, usage_count_from_orders)
    end

    private

    # Returns the usage claims count, excluding any orders with claims on this
    # promotion that are in the given list.
    #
    # @param orders [Array<Spree::Order>] Orders to exclude from usage count
    # @return [Integer] usage claims count excluding the given orders
    def usage_claims_count_excluding(orders)
      # Split excluded orders into those that are currently claiming this promotion and those that are not.
      claiming, others = orders.partition { |order| order.promotion_usage_claims&.include?(self) }

      # Of the excluded orders, find the ones that are completed and not canceled.
      completed_ids = others.select { _1.completed? && !_1.canceled? }.map(&:id)

      # Get the current usage claims count, either from the database if there
      # are any claiming orders or from the in-memory counter otherwise.
      count = claiming.any? ? self.class.where(id:).pick(:usage_claims_count) : usage_claims_count

      # Reduce count by any excluded orders that are currently claiming this promotion.
      count -= claiming.size

      # Further reduce count by any completed non-canceled orders from the
      # excluded orders that used this promotion.
      count -= usage_orders.where(id: completed_ids).count if completed_ids.any?

      count
    end
  end
end
