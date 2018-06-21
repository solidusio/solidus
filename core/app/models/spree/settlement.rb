# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    # @!scope class
    # @!attribute settlement_eligibility_validator
    # Configurable validator for determining whether given settlement is eligible
    # for settlement.
    # @return [Class]
    class_attribute :settlement_eligibility_validator
    self.settlement_eligibility_validator = Settlement::EligibilityValidator::Default

    belongs_to :reimbursement, inverse_of: :settlements
    belongs_to :reimbursement_type
    belongs_to :shipment, inverse_of: :settlements

    validate :shipment_belongs_to_same_order

    serialize :acceptance_status_errors

    delegate :eligible_for_settlement?, :requires_manual_intervention?, to: :validator

    before_create :set_default_amount, unless: :amount_changed?

    scope :pending, -> { where(acceptance_status: 'pending') }
    scope :not_pending, -> { where.not(acceptance_status: 'pending').order(:updated_at) }
    scope :accepted, -> { where(acceptance_status: 'accepted') }
    scope :rejected, -> { where(acceptance_status: 'rejected') }
    scope :manual_intervention_required, -> { where(acceptance_status: 'manual_intervention_required') }
    scope :unavailable_for_new_settlement, -> { where(acceptance_status: ['accepted', 'manual_intervention_required']) }

    scope :for_shipment, -> { where.not(shipment_id: nil) }
    scope :not_for_shipment, -> { where(shipment_id: nil) }
    scope :reimbursed, -> { where.not(reimbursement_id: nil) }
    scope :not_reimbursed, -> { where(reimbursement_id: nil) }

    extend DisplayMoney
    money_methods :amount, :total, :total_excluding_vat

    state_machine :acceptance_status, initial: :pending do
      event :attempt_accept do
        transition to: :accepted, from: :pending, if: ->(settlement) { settlement.eligible_for_settlement? }
        transition to: :manual_intervention_required, from: :pending, if: ->(settlement) { settlement.requires_manual_intervention? }
        transition to: :rejected, from: :pending
      end

      # bypasses eligibility checks
      event :accept do
        transition to: :accepted, from: [:pending, :manual_intervention_required]
      end

      # bypasses eligibility checks
      event :reject do
        transition to: :rejected, from: [:pending, :accepted, :manual_intervention_required]
      end

      after_transition any => any, do: :persist_acceptance_status_errors
    end

    # @return [BigDecimal] the cost of the item after tax
    def total
      amount + additional_tax_total
    end

    # @return [BigDecimal] the cost of the item before VAT tax
    def total_excluding_vat
      amount - included_tax_total
    end

    def set_default_amount
      self.amount = shipment.try(:amount) || 0
    end

    def unavailable_for_new_settlements?
      manual_intervention_required? || accepted?
    end

    private

    def persist_acceptance_status_errors
      update_attributes(acceptance_status_errors: validator.errors)
    end

    def validator
      @validator ||= settlement_eligibility_validator.new(self)
    end

    def shipment_belongs_to_same_order
      return unless shipment && reimbursement
      if reimbursement.order_id != shipment.order_id
        errors.add(:shipment, :must_belong_to_reimbursement_order)
      end
    end
  end
end
