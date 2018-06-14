# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class SettlementAmount < Spree::Settlement::EligibilityValidator::BaseValidator
        def eligible_for_settlement?
          return true unless @settlement.shipment
          if @settlement.amount > @settlement.shipment.cost
            add_error(:settlement_amount, I18n.t('spree.settlement_amount_greater_than_shipment_cost'))
            false
          else
            true
          end
        end

        def requires_manual_intervention?
          false
        end
      end
    end
  end
end
