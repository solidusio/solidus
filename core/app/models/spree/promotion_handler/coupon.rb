# frozen_string_literal: true

module Spree
  module PromotionHandler
    class Coupon
      extend ActiveModel::Naming

      attr_reader :order, :coupon_code, :errors
      attr_accessor :success

      def initialize(order)
        @order = order
        @coupon_code = order.coupon_code && order.coupon_code.downcase
        @errors = ActiveModel::Errors.new(self)
      end

      def apply
        if coupon_code.present?
          if promotion.present? && promotion.active? && promotion.actions.exists?
            handle_present_promotion(promotion)
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
          promotion.remove_from(order)
          order.recalculate
          set_success_code :coupon_code_removed
        end

        self
      end

      def set_success_code(status_code)
        @success = I18n.t(status_code, scope: 'spree')
        @success_status_code = status_code
      end

      def set_error_code(status_code, options = {})
        @errors.clear
        @errors.add(:base, options[:error] || I18n.t(status_code, scope: 'spree'), error_code: status_code)
      end

      def promotion
        @promotion ||= begin
          if promotion_code && promotion_code.promotion.active?
            promotion_code.promotion
          end
        end
      end

      def successful?
        success.present? && errors.empty?
      end

      def error
        Spree::Deprecation.warn "#error is deprecated. Please start using #errors."
        errors.full_messages.first
      end

      def status_code
        errors.any? ? errors.details[:base].first[:error_code] : @success_status_code
      end

      private

      def promotion_code
        @promotion_code ||= Spree::PromotionCode.where(value: coupon_code).first
      end

      def handle_present_promotion(promotion)
        return promotion_usage_limit_exceeded if promotion.usage_limit_exceeded? || promotion_code.usage_limit_exceeded?
        return promotion_applied if promotion_exists_on_order?(order, promotion)

        unless promotion.eligible?(order, promotion_code: promotion_code)
          @errors = promotion.eligibility_errors
          return (errors.any? || ineligible_for_this_order)
        end

        # If any of the actions for the promotion return `true`,
        # then result here will also be `true`.
        result = promotion.activate(order: order, promotion_code: promotion_code)
        if result
          order.recalculate
          set_success_code :coupon_code_applied
        else
          set_error_code :coupon_code_unknown_error
        end
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
        order.promotions.include? promotion
      end
    end
  end
end
