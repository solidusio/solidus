module Spree
  module Admin
    class StockTransfersController < ResourceController
      class_attribute :variant_display_attributes
      self.variant_display_attributes = [
        { string_key: :sku, attr_name: :sku },
        { string_key: :name, attr_name: :name }
      ]

      before_filter :load_stock_locations, only: [:index]

      def create
        variants = Hash.new(0)
        params[:variant].each_with_index do |variant_id, i|
          variants[variant_id] += params[:quantity][i].to_i
        end

        stock_transfer = StockTransfer.create(:reference => params[:reference])
        stock_transfer.transfer(source_location,
                                destination_location,
                                variants)

        flash[:success] = Spree.t(:stock_successfully_transferred)
        redirect_to admin_stock_transfer_path(stock_transfer)
      end

      def receive
        @received_items = @stock_transfer.transfer_items.received
        @variant_display_attributes = self.class.variant_display_attributes
      end

      protected

      def collection
        params[:q] = params[:q] || {}
        @search = super.ransack(params[:q])
        @search.result.
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      def find_resource
        model_class.find_by(number: params[:id])
      end

      private

      def load_stock_locations
        @stock_locations = Spree::StockLocation.accessible_by(current_ability, :index)
      end

      def source_location
        @source_location ||= params.has_key?(:transfer_receive_stock) ? nil :
                               StockLocation.find(params[:transfer_source_location_id])
      end

      def destination_location
        @destination_location ||= StockLocation.find(params[:transfer_destination_location_id])
      end
    end
  end
end
