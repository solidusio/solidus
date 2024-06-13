# frozen_string_literal: true

module SolidusFriendlyPromotions
  module PromotionHandler
    class Coupon
      attr_reader :order, :coupon_code, :errors
      attr_accessor :error, :success, :status_code

      def initialize(order)
        @order = order
        @errors = []
        @coupon_code = order&.coupon_code&.downcase
      end

      def apply
        if coupon_code.present?
          if promotion.present? && promotion.active?
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

      def successful?
        success.present? && error.blank?
      end

      def promotion
        @promotion ||= if promotion_code&.promotion&.active?
          promotion_code.promotion
        end
      end

      private

      def set_success_code(status_code)
        @status_code = status_code
        @success = I18n.t(status_code, scope: "solidus_friendly_promotions.eligibility_results")
      end

      def set_error_code(status_code, options = {})
        @status_code = status_code
        @error = options[:error] || I18n.t(status_code, scope: "solidus_friendly_promotions.eligibility_errors")
        @errors = options[:errors] || [@error]
      end

      def promotion_code
        @promotion_code ||= SolidusFriendlyPromotions::PromotionCode.where(value: coupon_code).first
      end

      def handle_present_promotion
        return promotion_usage_limit_exceeded if promotion.usage_limit_exceeded? || promotion_code.usage_limit_exceeded?
        return promotion_applied if promotion_exists_on_order?(order, promotion)

        # Try applying this promotion, with no effects
        Spree::Config.promotions.order_adjuster_class.new(order, dry_run_promotion: promotion).call

        if promotion.eligibility_results.success?
          order.friendly_order_promotions.create!(
            promotion: promotion,
            promotion_code: promotion_code
          )
          order.recalculate
          set_success_code :coupon_code_applied
        else
          set_promotion_eligibility_error(promotion)
        end
      end

      def set_promotion_eligibility_error(promotion)
        eligibility_error = promotion.eligibility_results.detect { |result| !result.success }
        set_error_code(eligibility_error.code, error: eligibility_error.message, errors: promotion.eligibility_results.error_messages)
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
