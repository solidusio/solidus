# frozen_string_literal: true
require 'spree/preferences/persistable'

module SolidusFriendlyPromotions
  # Base class for all types of promotion action.
  #
  # PromotionActions perform the necessary tasks when a promotion is activated
  # by an event and determined to be eligible.
  class Action < Spree::Base
    include Spree::Preferences::Persistable
    include Spree::SoftDeletable
    include Spree::CalculatedAdjustments
    include Spree::AdjustmentSource

    belongs_to :promotion, inverse_of: :actions
    has_many :adjustments, as: :source

    scope :of_type, ->(type) { where(type: Array.wrap(type).map(&:to_s)) }

    def preload_relations
      [:calculator]
    end

    def can_adjust?(object)
      raise NotImplementedError
    end

    def adjust(adjustable)
      adjustment = adjustable.adjustments.detect do |adjustment|
        adjustment.source == self
      end || adjustable.adjustments.build(source: self, order: adjustable.order)
      adjustment.label = adjustment_label(adjustable)
      adjustment.amount = compute_amount(adjustable)
      adjustment
    end

    # Ensure a negative amount which does not exceed the object's amount
    def compute_amount(adjustable)
      promotion_amount = calculator.compute(adjustable) || BigDecimal(0)
      [adjustable.amount, promotion_amount.abs].min * -1
    end

    def adjustment_label(adjustable)
      I18n.t(
        "spree.adjustment_labels.#{adjustable.class.name.demodulize.underscore}",
        promotion: Spree::Promotion.model_name.human,
        promotion_name: promotion.name,
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
