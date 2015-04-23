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

      def status(stock_transfer)
        stock_transfer.received? ? Spree.t(:closed) : Spree.t(:open)
      end
    end
  end
end
