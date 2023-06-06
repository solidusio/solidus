# frozen_string_literal: true

module SolidusFriendlyPromotions
  module OrderContentsDecorator
    private

    def after_add_or_remove(line_item, options = {})
      shipment = options[:shipment]
      shipment.present? ? shipment.update_amounts : order.ensure_updated_shipments
      reload_totals
      line_item
    end

    Spree::OrderContents.prepend self
  end
end
