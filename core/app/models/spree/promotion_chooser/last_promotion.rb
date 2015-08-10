module Spree
  module PromotionChooser
    class LastPromotion
      def initialize(adjustments)
        @adjustments = adjustments.select(&:eligible?).select(&:promotion?)
      end

      # Picks the last promotion applied to the order
      #
      # @return [BigDecimal] The amount of the last adjustment
      def update
        if last_promotion_adjustment
          @adjustments.each do |adjustment|
            next if adjustment == last_promotion_adjustment
            adjustment.update_columns(eligible: false)
          end
          last_promotion_adjustment.amount
        else
          BigDecimal.new('0')
        end
      end

      private

      # @return The last promotion adjustment from this set of adjustments.
      def last_promotion_adjustment
        @last_promotion_adjustment ||= @adjustments.max do |a,b|
          a.created_at <=> b.created_at
        end
      end
    end
  end
end
