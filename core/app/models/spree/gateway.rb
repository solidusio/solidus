module Spree
  # A concrete implementation of `Spree::PaymentMethod` intended to provide a
  # base for extension. See https://github.com/solidusio/solidus_gateway/ for
  # offically supported payment gateway implementations.
  #
  class Gateway < PaymentMethod
    def payment_source_class
      CreditCard
    end

    def method_type
      'gateway'
    end

    def supports?(source)
      return true unless provider_class.respond_to? :supports?
      return true if source.brand && provider_class.supports?(source.brand)
      source.has_payment_profile?
    end

    def reusable_sources_by_order(order)
      source_ids = order.payments.where(payment_method_id: id).pluck(:source_id).uniq
      payment_source_class.where(id: source_ids).select(&:reusable?)
    end
    alias_method :sources_by_order, :reusable_sources_by_order
    deprecate sources_by_order: :reusable_sources_by_order, deprecator: Spree::Deprecation

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
