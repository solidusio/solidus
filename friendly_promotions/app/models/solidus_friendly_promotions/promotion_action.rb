# frozen_string_literal: true

require "spree/preferences/persistable"

module SolidusFriendlyPromotions
  # Base class for all types of promotion action.
  #
  # PromotionActions perform the necessary tasks when a promotion is activated
  # by an event and determined to be eligible.
  class PromotionAction < Spree::Base
    include Spree::Preferences::Persistable
    include Spree::SoftDeletable
    include Spree::CalculatedAdjustments
    include Spree::AdjustmentSource

    belongs_to :promotion, inverse_of: :actions
    has_many :adjustments, class_name: "Spree::Adjustment", as: :source

    scope :of_type, ->(type) { where(type: Array.wrap(type).map(&:to_s)) }

    def preload_relations
      [:calculator]
    end

    def can_discount?(object)
      raise NotImplementedError
    end

    def discount(adjustable)
      ItemDiscount.new(
        item: adjustable,
        label: adjustment_label(adjustable),
        amount: compute_amount(adjustable),
        source: self
      )
    end

    # Ensure a negative amount which does not exceed the object's amount
    def compute_amount(adjustable)
      promotion_amount = calculator.compute(adjustable) || BigDecimal("0")
      [adjustable.discountable_amount, promotion_amount.abs].min * -1
    end

    def adjustment_label(adjustable)
      I18n.t(
        "solidus_friendly_promotions.adjustment_labels.#{adjustable.class.name.demodulize.underscore}",
        promotion: SolidusFriendlyPromotions::Promotion.model_name.human,
        promotion_name: promotion.name
      )
    end

    def to_partial_path
      "solidus_friendly_promotions/admin/promotion_actions/actions/#{model_name.element}"
    end

    def available_calculators
      raise NotImplementedError
    end
  end
end
