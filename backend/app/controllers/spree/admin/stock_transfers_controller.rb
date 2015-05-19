module Spree
  module Admin
    class StockTransfersController < ResourceController
      class_attribute :variant_display_attributes
      self.variant_display_attributes = [
        { translation_key: :sku, attr_name: :sku },
        { translation_key: :name, attr_name: :name }
      ]

      before_filter :load_stock_locations, only: [:index, :new]
      before_filter :load_variant_display_attributes, only: [:receive, :edit, :tracking_info]
      before_filter :load_destination_stock_locations, only: :edit
      before_filter :ensure_access_to_stock_location, only: :create
      before_filter :ensure_receivable_stock_transfer, only: :receive

      def receive
        @received_items = @stock_transfer.transfer_items.received
      end

      def finalize
        if @stock_transfer.finalize(try_spree_current_user)
          redirect_to tracking_info_admin_stock_transfer_path(@stock_transfer)
        else
          flash[:error] = @stock_transfer.errors.full_messages.join(", ")
          redirect_to edit_admin_stock_transfer_path(@stock_transfer)
        end
      end

      def close
        Spree::StockTransfer.transaction do
          if @stock_transfer.close(try_spree_current_user)
            adjust_inventory
            redirect_to admin_stock_transfers_path
          else
            flash[:error] = @stock_transfer.errors.full_messages.join(", ")
            redirect_to receive_admin_stock_transfer_path(@stock_transfer)
          end
        end
      end

      def ship
        if @stock_transfer.transfer
          @stock_transfer.ship(shipped_at: DateTime.now)
          flash[:success] = Spree.t(:stock_transfer_complete)
          redirect_to admin_stock_transfers_path
        else
          flash[:error] = @stock_transfer.errors.full_messages.join(", ")
          redirect_to tracking_info_admin_stock_transfer_path(@stock_transfer)
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

      def permitted_resource_params
        resource_params = super
        if action == :create
          resource_params.merge!(created_by: try_spree_current_user)
        end
        resource_params
      end

      def find_resource
        model_class.find_by(number: params[:id])
      end

      def render_after_create_error
        load_stock_locations
        super
      end

      def location_after_save
        if action == :create
          edit_admin_stock_transfer_path(@stock_transfer)
        else
          :back
        end
      end

      private

      def load_stock_locations
        @stock_locations = Spree::StockLocation.accessible_by(current_ability, :index)
      end

      def load_destination_stock_locations
        @destination_stock_locations = load_stock_locations.where.not(id: @stock_transfer.source_location_id)
      end

      def load_variant_display_attributes
        @variant_display_attributes = self.class.variant_display_attributes
      end

      def ensure_receivable_stock_transfer
        unless @stock_transfer.receivable?
          flash[:error] = Spree.t(:stock_transfer_must_be_receivable)
          redirect_to admin_stock_transfers_path and return
        end
      end

      def ensure_access_to_stock_location
        return unless permitted_resource_params[:source_location_id].present?
        authorize! :read, Spree::StockLocation.find(permitted_resource_params[:source_location_id])
      end

      def source_location
        @source_location ||= params.has_key?(:transfer_receive_stock) ? nil :
                               StockLocation.find(params[:transfer_source_location_id])
      end

      def destination_location
        @destination_location ||= StockLocation.find(params[:transfer_destination_location_id])
      end

      def adjust_inventory
        @stock_movements = @stock_transfer.transfer_items.received.map do |transfer_item|
          @stock_transfer.destination_location.move(transfer_item.variant, transfer_item.received_quantity, @stock_transfer)
        end
      end
    end
  end
end
