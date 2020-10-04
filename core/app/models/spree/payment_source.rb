# frozen_string_literal: true

module Spree
  class PaymentSource < Spree::Base
    self.abstract_class = true

    belongs_to :payment_method, optional: true

    has_many :payments, as: :source
    has_many :wallet_payment_sources, class_name: 'Spree::WalletPaymentSource', as: :payment_source, inverse_of: :payment_source

    attr_accessor :imported

    # @return [Array<String>] the actions available on this payment source
    def actions
      %w(capture void credit)
    end

    # @param payment [Spree::Payment] the payment we want to know if can be captured
    # @return [Boolean] true when the payment is in the pending or checkout states
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    # @param payment [Spree::Payment] the payment we want to know if can be voided
    # @return [Boolean] true when the payment is not failed or voided
    def can_void?(payment)
      !payment.failed? && !payment.void?
    end

    # Indicates whether its possible to credit the payment.  Note that most
    # gateways require that the payment be settled first which generally
    # happens within 12-24 hours of the transaction.
    #
    # @param payment [Spree::Payment] the payment we want to know if can be credited
    # @return [Boolean] true when the payment is completed and can be credited
    def can_credit?(payment)
      payment.completed? && payment.credit_allowed > 0
    end

    # Indicates whether this payment source can be used more than once. E.g. a
    # credit card with a 'payment profile'.
    def reusable?
      false
    end
  end
end
