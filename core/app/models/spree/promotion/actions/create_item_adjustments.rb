module Spree
  class Promotion
    module Actions
      class CreateItemAdjustments < PromotionAction
        include Spree::CalculatedAdjustments
        include Spree::AdjustmentSource

        has_many :adjustments, as: :source

        delegate :eligible?, to: :promotion

        before_validation :ensure_action_has_calculator
        before_destroy :deals_with_adjustments_for_deleted_source

        def perform(payload = {})
          order = payload[:order]
          promotion = payload[:promotion]
          promotion_code = payload[:promotion_code]

          result = false

          line_items_to_adjust(promotion, order).each do |line_item|
            current_result = create_adjustment(line_item, order, promotion_code)
            result ||= current_result
          end
          result
        end

        # Ensure a negative amount which does not exceed the sum of the order's
        # item_total and ship_total
        def compute_amount(adjustable)
          order = adjustable.is_a?(Order) ? adjustable : adjustable.order
          return 0 unless promotion.line_item_actionable?(order, adjustable)
          promotion_amount = calculator.compute(adjustable).to_f.abs
          [adjustable.amount, promotion_amount].min * -1
        end

        private

        def create_adjustment(adjustable, order, promotion_code)
          amount = compute_amount(adjustable)
          return if amount == 0
          adjustable.adjustments.create!(
            source: self,
            amount: amount,
            order: order,
            promotion_code: promotion_code,
            label: "#{Spree.t(:promotion)} (#{promotion.name})"
          )
          true
        end

        # Tells us if there if the specified promotion is already associated with the line item
        # regardless of whether or not its currently eligible. Useful because generally
        # you would only want a promotion action to apply to line item no more than once.
        #
        # Receives an adjustment +source+ (here a PromotionAction object) and tells
        # if the order has adjustments from that already
        def promotion_credit_exists?(adjustable)
          adjustments.where(adjustable_id: adjustable.id).exists?
        end

        def ensure_action_has_calculator
          return if calculator
          self.calculator = Calculator::PercentOnLineItem.new
        end

        def line_items_to_adjust(promotion, order)
          excluded_ids = adjustments.
            where(adjustable_id: order.line_items.pluck(:id), adjustable_type: 'Spree::LineItem').
            pluck(:adjustable_id).
            to_set

          order.line_items.select do |line_item|
            !excluded_ids.include?(line_item.id) &&
              promotion.line_item_actionable?(order, line_item)
          end
        end
      end
    end
  end
end
