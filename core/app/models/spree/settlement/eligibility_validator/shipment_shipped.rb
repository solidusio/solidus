# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class ShipmentShipped < Spree::Settlement::EligibilityValidator::BaseValidator
        def eligible_for_settlement?
          return unless @settlement.shipment
          if @settlement.shipment.shipped?
            true
          else
            add_error(:shipment_shipped, I18n.t('spree.settlement_shipment_ineligible'))
            false
          end
        end

        def requires_manual_intervention?
          @errors.present?
        end
      end
    end
  end
end
