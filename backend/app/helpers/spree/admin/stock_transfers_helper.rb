module Spree
  module Admin
    module StockTransfersHelper
      def handle_stock_transfer(stock_transfer)
        if can?(:show, stock_transfer)
          link_to stock_transfer.number, admin_stock_transfer_path(stock_transfer)
        else
          stock_transfer.number
        end
      end

      def stock_transfer_edit_or_ship_path(stock_transfer)
        if stock_transfer.finalized?
          tracking_info_admin_stock_transfer_path(stock_transfer)
        else
          edit_admin_stock_transfer_path(stock_transfer)
        end
      end

      def stock_transfer_status(stock_transfer)
        stock_transfer.closed? ? Spree.t(:closed) : Spree.t(:open)
      end

      def deleted_variant_admin_hint(variant)
        newer_variant_with_same_sku = Spree::Variant.find_by(sku: variant.sku)
        hint_type = newer_variant_with_same_sku ? :deleted_explanation_with_replacement : :deleted_explanation
        hint_text = I18n.t(
          hint_type,
          scope: [:spree, :hints, "spree/variant"],
          date: variant.deleted_at
        )
        admin_hint(
          I18n.t(:deleted, scope: [:spree, :hints, "spree/variant"]),
          hint_text
        )
      end
    end
  end
end
