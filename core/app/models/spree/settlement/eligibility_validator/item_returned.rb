# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class ItemReturned < Spree::Settlement::EligibilityValidator::BaseValidator
        def eligible_for_settlement?
          return unless @settlement.reimbursement && @settlement.shipment
          shipment_returned_items = Spree::ReturnItem
            .joins(inventory_unit: :shipment)
            .where("spree_shipments.id = ?", @settlement.shipment.id)
          if (shipment_returned_items & @settlement.reimbursement.return_items).any?
            true
          else
            add_error(:item_returned, I18n.t('spree.settlement_return_items_ineligible'))
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
