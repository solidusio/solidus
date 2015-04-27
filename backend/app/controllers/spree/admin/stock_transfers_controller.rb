module Spree
  module Admin
    class StockTransfersController < ResourceController
      class_attribute :variant_display_attributes
      self.variant_display_attributes = [
        { translation_key: :sku, attr_name: :sku },
        { translation_key: :name, attr_name: :name }
      ]

      before_filter :load_stock_locations, only: [:index]
      before_filter :ensure_receivable_stock_transfer, only: [:receive, :close]

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

      def close
        Spree::StockTransfer.transaction do
          if @stock_transfer.update_attributes(close_params)
            adjust_inventory
            redirect_to admin_stock_transfers_path
          else
            flash[:error] = Spree.t(:unable_to_finalize_stock_transfer)
            redirect_to receive_admin_stock_transfer_path(@stock_transfer)
          end
        end
      end

      protected

      def collection
        params[:q] = params[:q] || {}
        @show_only_open = if params[:q][:closed_at_null].present?
          params[:q][:closed_at_null] == '1'
        else
          true
        end
        params[:q].delete(:closed_at_null) unless @show_only_open
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

      def ensure_receivable_stock_transfer
        unless @stock_transfer.receivable?
          flash[:error] = Spree.t(:stock_transfer_must_be_receivable)
          redirect_to admin_stock_transfers_path and return
        end
      end

      def source_location
        @source_location ||= params.has_key?(:transfer_receive_stock) ? nil :
                               StockLocation.find(params[:transfer_source_location_id])
      end

      def destination_location
        @destination_location ||= StockLocation.find(params[:transfer_destination_location_id])
      end

      def close_params
        { closed_at: Time.now, closed_by: try_spree_current_user }
      end

      def adjust_inventory
        @stock_movements = @stock_transfer.transfer_items.received.map do |transfer_item|
          @stock_transfer.destination_location.move(transfer_item.variant, transfer_item.received_quantity, @stock_transfer)
        end
      end
    end
  end
end
