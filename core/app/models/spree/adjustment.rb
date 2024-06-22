# frozen_string_literal: true

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
    belongs_to :adjustable, polymorphic: true, touch: true, optional: true
    belongs_to :source, polymorphic: true, optional: true
    belongs_to :order, class_name: 'Spree::Order', inverse_of: :all_adjustments, optional: true
    belongs_to :adjustment_reason, class_name: 'Spree::AdjustmentReason', inverse_of: :adjustments, optional: true

    validates :adjustable, presence: true
    validates :order, presence: true
    validates :label, presence: true
    validates :amount, numericality: true

    scope :not_finalized, -> { where(finalized: false) }
    scope :finalized, -> { where(finalized: true) }
    scope :cancellation, -> { where(source_type: 'Spree::UnitCancel') }
    scope :tax, -> { where(source_type: 'Spree::TaxRate') }
    scope :non_tax, -> do
      source_type = arel_table[:source_type]
      where(source_type.not_eq('Spree::TaxRate').or(source_type.eq(nil)))
    end
    scope :price, -> { where(adjustable_type: 'Spree::LineItem') }
    scope :shipping, -> { where(adjustable_type: 'Spree::Shipment') }
    scope :eligible, -> { all }
    class << self
      deprecate :eligible, deprecator: Spree.deprecator
    end
    scope :charge, -> { where("#{quoted_table_name}.amount >= 0") }
    scope :credit, -> { where("#{quoted_table_name}.amount < 0") }
    scope :nonzero, -> { where("#{quoted_table_name}.amount != 0") }
    scope :promotion, -> { where(source_type: Spree::Config.adjustment_promotion_source_types.map(&:to_s)) }
    scope :non_promotion, -> { where.not(source_type: Spree::Config.adjustment_promotion_source_types.map(&:to_s)) }
    scope :return_authorization, -> { where(source_type: "Spree::ReturnAuthorization") }
    scope :is_included, -> { where(included: true) }
    scope :additional, -> { where(included: false) }

    singleton_class.deprecate :return_authorization, deprecator: Spree.deprecator

    allowed_ransackable_attributes << 'label'

    extend DisplayMoney
    money_methods :amount

    def finalize!
      update!(finalized: true)
    end

    def unfinalize!
      update!(finalized: false)
    end

    def finalize
      update(finalized: true)
    end

    def unfinalize
      update(finalized: false)
    end

    def currency
      adjustable ? adjustable.currency : Spree::Config[:currency]
    end

    # @return [Boolean] true when this is a promotion adjustment (Promotion adjustments have a {PromotionAction} source)
    def promotion?
      source_type.to_s.in?(Spree::Config.adjustment_promotion_source_types.map(&:to_s))
    end

    # @return [Boolean] true when this is a tax adjustment (Tax adjustments have a {TaxRate} source)
    def tax?
      source_type == 'Spree::TaxRate'
    end

    # @return [Boolean] true when this is a cancellation adjustment (Cancellation adjustments have a {UnitCancel} source)
    def cancellation?
      source_type == 'Spree::UnitCancel'
    end

    def eligible?
      true
    end
    alias_method :eligible, :eligible?
  end
end
