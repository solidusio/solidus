# frozen_string_literal: true

module SolidusFriendlyPromotions
  module PromotionHandler
    class Coupon
      attr_reader :order, :coupon_code
      attr_accessor :error, :success, :status_code

      def initialize(order)
        @order = order
        @coupon_code = order&.coupon_code&.downcase
      end

      def apply
        if coupon_code.present?
          if promotion.present? && promotion.active? && promotion.actions.exists?
            handle_present_promotion
          elsif promotion_code&.promotion&.expired?
            set_error_code :coupon_code_expired
          else
            set_error_code :coupon_code_not_found
          end
        end

        self
      end

      def remove
        if promotion.blank?
          set_error_code :coupon_code_not_found
        elsif !promotion_exists_on_order?(order, promotion)
          set_error_code :coupon_code_not_present
        else
          order.friendly_order_promotions.destroy_by(
            promotion: promotion
          )
          order.recalculate
          set_success_code :coupon_code_removed
        end

        self
      end

      def set_success_code(status_code)
        @status_code = status_code
        @success = I18n.t(status_code, scope: "solidus_friendly_promotions.eligibility_results")
      end

      def set_error_code(status_code, options = {})
        @status_code = status_code
        @error = options[:error] || I18n.t(status_code, scope: "solidus_friendly_promotions.eligibility_errors")
      end

      def promotion
        @promotion ||= if promotion_code&.promotion&.active?
          promotion_code.promotion
        end
      end

      def successful?
        success.present? && error.blank?
      end

      private

      def promotion_code
        @promotion_code ||= SolidusFriendlyPromotions::PromotionCode.where(value: coupon_code).first
      end

      def handle_present_promotion
        return promotion_usage_limit_exceeded if promotion.usage_limit_exceeded? || promotion_code.usage_limit_exceeded?
        return promotion_applied if promotion_exists_on_order?(order, promotion)

        # Try applying this promotion, with no effects
        active_promotions = SolidusFriendlyPromotions::PromotionLoader.new(order: order).call
        discounter = SolidusFriendlyPromotions::FriendlyPromotionDiscounter.new(order, active_promotions + [promotion], collect_eligibility_results: true)
        discounter.call
        if discounter.eligibility_results.success?(promotion)
          order.friendly_order_promotions.create!(
            promotion: promotion,
            promotion_code: promotion_code
          )
          order.recalculate
          set_success_code :coupon_code_applied
        else
          set_promotion_eligibility_error(promotion, discounter.eligibility_results)
        end
      end

      def set_promotion_eligibility_error(promotion, results)
        eligibility_error = results.for(promotion).values.flatten.detect { |result| !result.success }

        @status_code = eligibility_error.code
        @error = eligibility_error.message
      end

      def promotion_usage_limit_exceeded
        set_error_code :coupon_code_max_usage
      end

      def ineligible_for_this_order
        set_error_code :coupon_code_not_eligible
      end

      def promotion_applied
        set_error_code :coupon_code_already_applied
      end

      def promotion_exists_on_order?(order, promotion)
        order.friendly_promotions.include? promotion
      end
    end
  end
end
