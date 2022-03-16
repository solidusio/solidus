# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Actions
      class FreeShipping < Spree::PromotionAction
        def can_discount?(klass)
          klass == Spree::Shipment
        end

        def discount(shipment)
          discount = shipment.discounts.detect do |discount|
            discount.promotion_action == self
          end || shipment.discounts.build(promotion_action: self)
          discount.label = I18n.t('spree.adjustment_labels.shipment', promotion: Spree::Promotion.model_name.human, promotion_name: promotion.name)
          discount.amount = compute_amount(shipment)
          discount
        end

        def perform(payload = {})
          order = payload[:order]
          promotion_code = payload[:promotion_code]

          created_adjustments = order.shipments.map do |shipment|
            next if promotion_credit_exists?(shipment)

            shipment.adjustments.create!(
              order: shipment.order,
              amount: compute_amount(shipment),
              source: self,
              promotion_code: promotion_code,
              label: label
            )
          end

          # Did we actually end up creating any adjustments?
          # If so, then this action should be classed as 'successful'
          created_adjustments.any?
        end

        def label
          "#{I18n.t('spree.promotion')} (#{promotion.name})"
        end

        def compute_amount(shipment)
          shipment.cost * -1
        end

        # Removes any adjustments generated by this action from the order's
        #  shipments.
        # @param order [Spree::Order] the order to remove the action from.
        # @return [void]
        def remove_from(order)
          order.shipments.each do |shipment|
            shipment.adjustments.each do |adjustment|
              if adjustment.source == self
                shipment.adjustments.destroy(adjustment)
              end
            end
          end
        end

        private

        def promotion_credit_exists?(shipment)
          shipment.adjustments.where(source: self).exists?
        end
      end
    end
  end
end
