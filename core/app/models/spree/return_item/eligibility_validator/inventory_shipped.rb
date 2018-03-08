# frozen_string_literal: true

module Spree
  class ReturnItem < Spree::Base
    module EligibilityValidator
      class InventoryShipped < Spree::ReturnItem::EligibilityValidator::BaseValidator
        def eligible_for_return?
          if @return_item.inventory_unit.shipped?
            true
          else
            add_error(:inventory_unit_shipped, I18n.t('spree.return_item_inventory_unit_ineligible'))
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
