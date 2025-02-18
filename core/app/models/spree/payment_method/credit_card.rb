# frozen_string_literal: true

module Spree
  # An implementation of a `Spree::PaymentMethod` for credit card payments.
  #
  # It's a good candidate as base class for other credit card based payment methods.
  class PaymentMethod::CreditCard < PaymentMethod
    def payment_source_class
      Spree::CreditCard
    end

    def partial_name
      "gateway"
    end

    def supports?(source)
      return true unless gateway_class.respond_to? :supports?
      return true if source.brand && gateway_class.supports?(source.brand)
      source.has_payment_profile?
    end

    def reusable_sources_by_order(order)
      source_ids = order.payments.where(payment_method_id: id).pluck(:source_id).uniq
      payment_source_class.where(id: source_ids).select(&:reusable?)
    end

    def reusable_sources(order)
      if order.completed?
        reusable_sources_by_order(order)
      elsif order.user_id
        order.user.wallet.wallet_payment_sources.map(&:payment_source).select(&:reusable?)
      else
        []
      end
    end
  end
end
