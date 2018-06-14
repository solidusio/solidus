# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class SettlementExists < Spree::Settlement::EligibilityValidator::BaseValidator
        def eligible_for_settlement?
          return true unless @settlement.shipment
          if Spree::Settlement
            .where(shipment: @settlement.shipment, acceptance_status: 'accepted')
            .where.not(id: @settlement.id).empty?
            true
          else
            add_error(:settlement_already_exists, I18n.t('spree.settlement_already_exists_for_shipment'))
            false
          end
        end

        def requires_manual_intervention?
          false
        end
      end
    end
  end
end
