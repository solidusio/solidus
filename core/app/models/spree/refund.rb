# frozen_string_literal: true

module Spree
  class Refund < Spree::Base
    include Metadata

    belongs_to :payment, inverse_of: :refunds, optional: true
    belongs_to :reason,
      class_name: 'Spree::RefundReason',
      foreign_key: :refund_reason_id,
      optional: true,
      inverse_of: :refunds
    belongs_to :reimbursement, inverse_of: :refunds, optional: true

    has_many :log_entries, as: :source, dependent: :destroy

    validates :payment, presence: true
    validates :reason, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }

    validate :amount_is_less_than_or_equal_to_allowed_amount, on: :create

    attr_reader :perform_response

    scope :non_reimbursement, -> { where(reimbursement_id: nil) }

    delegate :currency, to: :payment

    def money
      Spree::Money.new(amount, { currency: })
    end
    alias display_amount money

    class << self
      def total_amount_reimbursed_for(reimbursement)
        reimbursement.refunds.to_a.sum(&:amount)
      end
    end

    # Sets this price's amount to a new value, parsing it if the new value is
    # a string.
    #
    # @param price [String, #to_d] a new amount
    def amount=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end

    def description
      payment.payment_method.name
    end

    # Must be called for the refund transaction to be processed.
    #
    # Attempts to perform the refund,
    # raises an error if the refund fails.
    def perform!
      return true if transaction_id.present?

      credit_cents = money.cents

      @perform_response = process!(credit_cents)
      log_entries.build(parsed_payment_response_details_with_fallback: perform_response)

      self.transaction_id = perform_response.authorization
      save!

      update_order
    end

    private

    # return an activemerchant response object if successful or else raise an error
    def process!(credit_cents)
      response = if payment.payment_method.payment_profiles_supported?
        payment.payment_method.credit(credit_cents, payment.source, payment.transaction_id, { originator: self })
      else
        payment.payment_method.credit(credit_cents, payment.transaction_id, { originator: self })
      end

      if !response.success?
        logger.error(I18n.t('spree.gateway_error') + "  #{response.to_yaml}")
        text = response.params['message'] || response.params['response_reason_text'] || response.message
        raise Core::GatewayError.new(text)
      end

      response
    rescue ActiveMerchant::ConnectionError => error
      logger.error(I18n.t('spree.gateway_error') + "  #{error.inspect}")
      raise Core::GatewayError.new(I18n.t('spree.unable_to_connect_to_gateway'))
    end

    def amount_is_less_than_or_equal_to_allowed_amount
      if payment && amount > payment.credit_allowed
        errors.add(:amount, :greater_than_allowed)
      end
    end

    def update_order
      payment.order.recalculate
    end
  end
end
