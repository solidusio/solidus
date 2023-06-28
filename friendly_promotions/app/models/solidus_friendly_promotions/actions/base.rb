# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class Base < ::Spree::PromotionAction
      include Spree::CalculatedAdjustments
      include Spree::AdjustmentSource

      has_many :adjustments, as: :source

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
end
