# frozen_string_literal: true

module Spree
  class ReturnItem < Spree::Base
    INTERMEDIATE_RECEPTION_STATUSES = %i(given_to_customer lost_in_transit shipped_wrong_item short_shipped in_transit)
    COMPLETED_RECEPTION_STATUSES = INTERMEDIATE_RECEPTION_STATUSES + [:received]

    # @!scope class
    # @!attribute return_eligibility_validator
    # Configurable validator for determining whether given return item is
    # eligible for return.
    # @return [Class]
    class_attribute :return_eligibility_validator
    self.return_eligibility_validator = ReturnItem::EligibilityValidator::Default

    # @!scope class
    # @!attribute exchange_variant_engine
    # Configurable engine for determining which variants can be exchanged for a
    # given variant.
    # @return [Class]
    class_attribute :exchange_variant_engine
    self.exchange_variant_engine = ReturnItem::ExchangeVariantEligibility::SameProduct

    # @!scope class
    # @!attribute refund_amount_calculator
    # Configurable calculator for determining the amount ro refund when
    # refunding.
    # @return [Class]
    class_attribute :refund_amount_calculator
    self.refund_amount_calculator = Calculator::Returns::DefaultRefundAmount

    belongs_to :return_authorization, inverse_of: :return_items, optional: true
    belongs_to :inventory_unit, inverse_of: :return_items, optional: true
    belongs_to :exchange_variant, class_name: 'Spree::Variant', optional: true
    belongs_to :exchange_inventory_unit, class_name: 'Spree::InventoryUnit', inverse_of: :original_return_item, optional: true
    belongs_to :customer_return, inverse_of: :return_items, optional: true
    belongs_to :reimbursement, inverse_of: :return_items, optional: true
    belongs_to :preferred_reimbursement_type, class_name: 'Spree::ReimbursementType', optional: true
    belongs_to :override_reimbursement_type, class_name: 'Spree::ReimbursementType', optional: true
    belongs_to :return_reason, class_name: 'Spree::ReturnReason', foreign_key: :return_reason_id, optional: true

    validate :eligible_exchange_variant
    validate :belongs_to_same_customer_order
    validate :validate_acceptance_status_for_reimbursement
    validates :inventory_unit, presence: true
    validate :validate_no_other_completed_return_items

    after_create :cancel_others, unless: :cancelled?

    scope :awaiting_return, -> { where(reception_status: 'awaiting') }
    scope :expecting_return, -> { where.not(reception_status: COMPLETED_RECEPTION_STATUSES) }
    scope :not_cancelled, -> { where.not(reception_status: 'cancelled') }
    scope :valid, -> { where.not(reception_status: %w(cancelled expired unexchanged)) }
    scope :not_expired, -> { where.not(reception_status: 'expired') }
    scope :received, -> { where(reception_status: 'received') }
    INTERMEDIATE_RECEPTION_STATUSES.each do |reception_status|
      scope reception_status, -> { where(reception_status: reception_status) }
    end
    scope :pending, -> { where(acceptance_status: 'pending') }
    scope :accepted, -> { where(acceptance_status: 'accepted') }
    scope :rejected, -> { where(acceptance_status: 'rejected') }
    scope :manual_intervention_required, -> { where(acceptance_status: 'manual_intervention_required') }
    scope :undecided, -> { where(acceptance_status: %w(pending manual_intervention_required)) }
    scope :decided, -> { where.not(acceptance_status: %w(pending manual_intervention_required)) }
    scope :reimbursed, -> { where.not(reimbursement_id: nil) }
    scope :not_reimbursed, -> { where(reimbursement_id: nil) }
    scope :exchange_requested, -> { where.not(exchange_variant: nil) }
    scope :exchange_processed, -> { where.not(exchange_inventory_unit: nil) }
    scope :exchange_required, -> { exchange_requested.where(exchange_inventory_unit: nil) }

    serialize :acceptance_status_errors

    delegate :eligible_for_return?, :requires_manual_intervention?, to: :validator
    delegate :variant, to: :inventory_unit
    delegate :shipment, to: :inventory_unit

    before_create :set_default_amount, unless: :amount_changed?
    before_save :set_exchange_amount

    include ::Spree::Config.state_machines.return_item_reception
    include ::Spree::Config.state_machines.return_item_acceptance

    extend DisplayMoney
    money_methods :pre_tax_amount, :amount, :total, :total_excluding_vat
    deprecate display_pre_tax_amount: :display_total_excluding_vat, deprecator: Spree::Deprecation

    # @return [Boolean] true when this retur item is in a complete reception
    #   state
    def reception_completed?
      COMPLETED_RECEPTION_STATUSES.map(&:to_s).include?(reception_status.to_s)
    end


    attr_accessor :skip_customer_return_processing

    # @param inventory_unit [Spree::InventoryUnit] the inventory for which we
    #   want a return item
    # @return [Spree::ReturnItem] a valid return item for the given inventory
    #   unit if one exists, or a new one if one does not
    def self.from_inventory_unit(inventory_unit)
      valid.find_by(inventory_unit: inventory_unit) ||
        new(inventory_unit: inventory_unit).tap(&:set_default_amount)
    end

    # @return [Boolean] true when an exchange has been requested on this return
    #   item
    def exchange_requested?
      exchange_variant.present?
    end

    # @return [Boolean] true when an exchange has been processed for this
    #   return item
    def exchange_processed?
      exchange_inventory_unit.present?
    end

    # @return [Boolean] true when an exchange has been requested but has yet to
    #   be processed
    def exchange_required?
      exchange_requested? && !exchange_processed?
    end

    # @return [BigDecimal] the cost of the item after tax
    def total
      amount + additional_tax_total
    end

    # @return [BigDecimal] the cost of the item before VAT tax
    def total_excluding_vat
      amount - included_tax_total
    end
    alias pre_tax_amount total_excluding_vat
    deprecate pre_tax_amount: :total_excluding_vat, deprecator: Spree::Deprecation

    # @note This uses the exchange_variant_engine configured on the class.
    # @param stock_locations [Array<Spree::StockLocation>] the stock locations to check
    # @return [ActiveRecord::Relation<Spree::Variant>] the variants eligible
    #   for exchange for this return item
    def eligible_exchange_variants(stock_locations = nil)
      exchange_variant_engine.eligible_variants(variant, stock_locations: stock_locations)
    end

    # Builds the exchange inventory unit for this return item, only if an
    # exchange is required, correctly associating the variant, line item and
    # order.
    def build_exchange_inventory_unit
      # The inventory unit needs to have the new variant
      # but it also needs to know the original line item
      # for pricing information for if the inventory unit is
      # ever returned. This means that the inventory unit's line_item
      # will have a different variant than the inventory unit itself
      super(variant: exchange_variant, line_item: inventory_unit.line_item) if exchange_required?
    end

    # @return [Spree::Shipment, nil] the exchange inventory unit's shipment if it exists
    def exchange_shipment
      exchange_inventory_unit.try(:shipment)
    end

    # Calculates and sets the default amount to be refunded.
    #
    # @note This uses the configured refund_amount_calculator configured on the
    #   class.
    def set_default_amount
      self.amount = refund_amount_calculator.new.compute(self)
    end

    def potential_reception_transitions
      status_paths = reception_status_paths.to_states
      event_paths = reception_status_paths.events
      status_paths.delete(:cancelled)
      status_paths.delete(:expired)
      status_paths.delete(:unexchanged)
      event_paths.delete(:cancel)
      event_paths.delete(:expired)
      event_paths.delete(:unexchange)

      status_paths.map{ |status| I18n.t("spree.reception_states.#{status}", default: status.to_s.humanize) }.zip(event_paths)
    end

    def part_of_exchange?
      # test whether this ReturnItem was either a) one for which an exchange was sent or
      #   b) the exchanged item itself being returned in lieu of the original item
      exchange_requested? || sibling_intended_for_exchange('unexchanged')
    end

    private

    def persist_acceptance_status_errors
      update(acceptance_status_errors: validator.errors)
    end

    def currency
      return_authorization.try(:currency) || Spree::Config[:currency]
    end

    def process_inventory_unit!
      inventory_unit.return!
      if customer_return
        customer_return.stock_location.restock(inventory_unit.variant, 1, customer_return) if should_restock?
        unless skip_customer_return_processing
          Deprecation.warn 'From Solidus v2.9 onwards, #process_inventory_unit! will not call customer_return#process_return!'
          customer_return.process_return!
        end
      end
    end

    def sibling_intended_for_exchange(status)
      # This happens when we ship an exchange to a customer, but the customer keeps the original and returns the exchange
      self.class.find_by(reception_status: status, exchange_inventory_unit: inventory_unit)
    end

    def check_unexchange
      original_ri = sibling_intended_for_exchange('awaiting')
      if original_ri
        original_ri.unexchange!
        set_default_amount
        save!
      end
    end

    # This logic is also present in the customer return. The reason for the
    # duplication and not having a validates_associated on the customer_return
    # is that it would lead to duplicate error messages for the customer return.
    # Not specifying a stock location for example would add an error message about
    # the mandatory field when validating the customer return and again when saving
    # the associated return items.
    def belongs_to_same_customer_order
      return unless customer_return && inventory_unit

      if customer_return.order_id != inventory_unit.order_id
        errors.add(:base, I18n.t('spree.return_items_cannot_be_associated_with_multiple_orders'))
      end
    end

    def eligible_exchange_variant
      return unless exchange_variant && exchange_variant_id_changed?
      unless eligible_exchange_variants.include?(exchange_variant)
        errors.add(:base, I18n.t('spree.invalid_exchange_variant'))
      end
    end

    def validator
      @validator ||= return_eligibility_validator.new(self)
    end

    def validate_acceptance_status_for_reimbursement
      if reimbursement && !accepted?
        errors.add(:reimbursement, :cannot_be_associated_unless_accepted)
      end
    end

    def set_exchange_amount
      self.amount = 0.0.to_d if exchange_requested?
    end

    def validate_no_other_completed_return_items
      other_return_item = Spree::ReturnItem.where({
        inventory_unit_id: inventory_unit_id,
        reception_status: COMPLETED_RECEPTION_STATUSES
      }).where.not(id: id).first

      if other_return_item && (new_record? || COMPLETED_RECEPTION_STATUSES.include?(reception_status.to_sym))
        errors.add(:inventory_unit, :other_completed_return_item_exists, {
          inventory_unit_id: inventory_unit_id,
          return_item_id: other_return_item.id
        })
      end
    end

    def cancel_others
      Spree::ReturnItem.where(inventory_unit_id: inventory_unit_id)
                       .where.not(id: id)
                       .valid
                       .each(&:cancel!)
    end

    def should_restock?
      resellable? &&
        variant.should_track_inventory? &&
        customer_return &&
        customer_return.stock_location.restock_inventory?
    end
  end
end
