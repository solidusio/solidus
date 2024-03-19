# frozen_string_literal: true

module Spree
  class NullPromotionHandler
    attr_reader :order, :coupon_code

    def initialize(order)
      @order = order
      @coupon_code = order.coupon_code&.downcase
    end

    def activate
      @order
    end
    alias_method :apply, :activate

    def can_apply?
      true
    end

    def error
      nil
    end

    def success
      true
    end

    def successful?
      true
    end

    def status_code
      :coupon_code_applied
    end

    def status
      I18n.t(:coupon_code_applied, scope: [:spree, :null_promotion_handler])
    end
  end
end
