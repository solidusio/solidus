module Spree
  # Adjustments represent a change to the +item_total+ of an Order. Each
  # adjustment has an +amount+ that can be either positive or negative.
  #
  # Adjustments can be "opened" or "closed". Once an adjustment is closed, it
  # will not be automatically updated.
  #
  # == Boolean attributes
  #
  # 1. *eligible?*
  #
  #    This boolean attributes stores whether this adjustment is currently
  #    eligible for its order. Only eligible adjustments count towards the
  #    order's adjustment total. This allows an adjustment to be preserved if
  #    it becomes ineligible so it might be reinstated.
  class Adjustment < Spree::Base
    belongs_to :adjustable, polymorphic: true, touch: true
    belongs_to :source, polymorphic: true
    belongs_to :order, class_name: 'Spree::Order', inverse_of: :all_adjustments
    belongs_to :promotion_code, class_name: 'Spree::PromotionCode'
    belongs_to :adjustment_reason, class_name: 'Spree::AdjustmentReason', inverse_of: :adjustments

    validates :adjustable, presence: true
    validates :order, presence: true
    validates :label, presence: true
    validates :amount, numericality: true
    validates :promotion_code, presence: true, if: :require_promotion_code?

    # We need to use `after_commit` here because otherwise it's too early to
    # tell if any repair is needed.
    after_commit :repair_adjustments_associations_on_create, on: [:create]
    after_commit :repair_adjustments_associations_on_destroy, on: [:destroy]

    scope :not_finalized, -> { where(finalized: false) }
    scope :open, -> do
      Spree::Deprecation.warn "Adjustment.open is deprecated. Instead use Adjustment.not_finalized", caller
      where(finalized: false)
    end
    scope :finalized, -> { where(finalized: true) }
    scope :closed, -> do
      Spree::Deprecation.warn "Adjustment.closed is deprecated. Instead use Adjustment.finalized", caller
      where(finalized: true)
    end
    scope :cancellation, -> { where(source_type: 'Spree::UnitCancel') }
    scope :tax, -> { where(source_type: 'Spree::TaxRate') }
    scope :non_tax, -> do
      source_type = arel_table[:source_type]
      where(source_type.not_eq('Spree::TaxRate').or(source_type.eq(nil)))
    end
    scope :price, -> { where(adjustable_type: 'Spree::LineItem') }
    scope :shipping, -> { where(adjustable_type: 'Spree::Shipment') }
    scope :eligible, -> { where(eligible: true) }
    scope :charge, -> { where("#{quoted_table_name}.amount >= 0") }
    scope :credit, -> { where("#{quoted_table_name}.amount < 0") }
    scope :nonzero, -> { where("#{quoted_table_name}.amount != 0") }
    scope :promotion, -> { where(source_type: 'Spree::PromotionAction') }
    scope :non_promotion, -> { where.not(source_type: 'Spree::PromotionAction') }
    scope :return_authorization, -> { where(source_type: "Spree::ReturnAuthorization") }
    scope :is_included, -> { where(included: true) }
    scope :additional, -> { where(included: false) }

    extend DisplayMoney
    money_methods :amount

    def finalize!
      update_attributes!(finalized: true)
    end

    def unfinalize!
      update_attributes!(finalized: false)
    end

    def finalize
      update_attributes(finalized: true)
    end

    def unfinalize
      update_attributes(finalized: false)
    end

    # Deprecated methods
    def state
      Spree::Deprecation.warn "Adjustment#state is deprecated. Instead use Adjustment#finalized?", caller
      finalized? ? "closed" : "open"
    end

    def state=(new_state)
      Spree::Deprecation.warn "Adjustment#state= is deprecated. Instead use Adjustment#finalized=", caller
      case new_state
      when "open"
        self.finalized = false
      when "closed"
        self.finalized = true
      else
        raise "invaliid adjustment state #{new_state}"
      end
    end

    def open?
      Spree::Deprecation.warn "Adjustment#open? is deprecated. Instead use Adjustment#finalized?", caller
      !closed?
    end

    def closed?
      Spree::Deprecation.warn "Adjustment#closed? is deprecated. Instead use Adjustment#finalized?", caller
      finalized?
    end

    def open
      Spree::Deprecation.warn "Adjustment#open is deprecated. Instead use Adjustment#unfinalize", caller
      unfinalize
    end

    def open!
      Spree::Deprecation.warn "Adjustment#open! is deprecated. Instead use Adjustment#unfinalize!", caller
      unfinalize!
    end

    def close
      Spree::Deprecation.warn "Adjustment#close is deprecated. Instead use Adjustment#finalize", caller
      finalize
    end

    def close!
      Spree::Deprecation.warn "Adjustment#close! is deprecated. Instead use Adjustment#finalize!", caller
      finalize!
    end
    # End deprecated methods

    def currency
      adjustable ? adjustable.currency : Spree::Config[:currency]
    end

    # @return [Boolean] true when this is a promotion adjustment (Promotion adjustments have a {PromotionAction} source)
    def promotion?
      source_type == 'Spree::PromotionAction'
    end

    # @return [Boolean] true when this is a tax adjustment (Tax adjustments have a {TaxRate} source)
    def tax?
      source_type == 'Spree::TaxRate'
    end

    # @return [Boolean] true when this is a cancellation adjustment (Cancellation adjustments have a {UnitCancel} source)
    def cancellation?
      source_type == 'Spree::UnitCancel'
    end

    # Recalculate and persist the amount from this adjustment's source based on
    # the adjustable ({Order}, {Shipment}, or {LineItem})
    #
    # If the adjustment has no source (such as when created manually from the
    # admin) or is closed, this is a noop.
    #
    # @param target [Spree::LineItem,Spree::Shipment,Spree::Order] Deprecated: the target to calculate against
    # @return [BigDecimal] New amount of this adjustment
    def update!(target = nil)
      if target
        Spree::Deprecation.warn("Passing a target to Adjustment#update! is deprecated. The adjustment will use the correct target from it's adjustable association.", caller)
      end
      return amount if finalized?

      # If the adjustment has no source, do not attempt to re-calculate the amount.
      # Chances are likely that this was a manually created adjustment in the admin backend.
      if source.present?
        self.amount = source.compute_amount(target || adjustable)

        if promotion?
          self.eligible = source.promotion.eligible?(adjustable, promotion_code: promotion_code)
        end

        # Persist only if changed
        # This is only not a save! to avoid the extra queries to load the order
        # (for validations) and to touch the adjustment.
        update_columns(eligible: eligible, amount: amount, updated_at: Time.current) if changed?
      end
      amount
    end

    private

    def require_promotion_code?
      promotion? && source.promotion.codes.any?
    end

    def repair_adjustments_associations_on_create
      if adjustable.adjustments.loaded? && !adjustable.adjustments.include?(self)
        Spree::Deprecation.warn("Adjustment was not added to #{adjustable.class}. Add adjustments via `adjustable.adjustments.create!`. Partial call stack: #{caller.select { |line| line =~ %r(/(app|spec)/) }}.", caller)
        adjustable.adjustments.proxy_association.add_to_target(self)
      end
    end

    def repair_adjustments_associations_on_destroy
      if adjustable.adjustments.loaded? && adjustable.adjustments.include?(self)
        Spree::Deprecation.warn("Adjustment was not removed from #{adjustable.class}. Remove adjustments via `adjustable.adjustments.destroy`. Partial call stack: #{caller.select { |line| line =~ %r(/(app|spec)/) }}.", caller)
        adjustable.adjustments.proxy_association.target.delete(self)
      end
    end
  end
end
