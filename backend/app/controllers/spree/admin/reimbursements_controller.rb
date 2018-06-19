# frozen_string_literal: true

module Spree
  module Admin
    class ReimbursementsController < ResourceController
      helper 'spree/admin/reimbursement_type'
      helper 'spree/admin/customer_returns'
      belongs_to 'spree/order', find_by: :number

      before_action :load_stock_locations, only: :edit
      before_action :load_simulated_refunds, only: :edit
      before_action :load_settlements, only: :edit
      after_action :attempt_accept_new_settlements, only: :update

      rescue_from Spree::Core::GatewayError, with: :spree_core_gateway_error

      def perform
        @reimbursement.perform!
        redirect_to location_after_save
      end

      private

      def build_resource
        if params[:build_from_customer_return_id].present?
          customer_return = Spree::CustomerReturn.find(params[:build_from_customer_return_id])

          Spree::Reimbursement.build_from_customer_return(customer_return)
        else
          super
        end
      end

      def location_after_save
        if @reimbursement.reimbursed?
          admin_order_reimbursement_path(parent, @reimbursement)
        else
          edit_admin_order_reimbursement_path(parent, @reimbursement)
        end
      end

      # We don't currently have a real Reimbursement "new" page. And the only
      # built-in way to create reimbursements via Solidus admin is from the
      # customer returns admin page via a button that supplies the
      # "build_from_customer_return" parameter. The "edit" page is not
      # suitable for use here for that reason as well.
      # Perhaps we should add a reimbursement new page of some sort.
      def render_after_create_error
        flash.keep
        if request.referer
          redirect_to request.referer
        else
          redirect_to admin_url
        end
      end

      def load_stock_locations
        @stock_locations = Spree::StockLocation.active
      end

      # To satisfy how nested attributes works we want to create placeholder Settlements for
      # any Shipments associated with a returned InventoryUnit.
      def load_settlements
        returned_items_shipments = @reimbursement.return_items.map(&:shipment).uniq
        unavailable_shipments = @reimbursement.settlements.unavailable_for_new_settlement.map(&:shipment)
        available_shipments = returned_items_shipments - unavailable_shipments

        @form_settlements = available_shipments.map do |shipment|
          Spree::Settlement.new(shipment: shipment, amount: shipment.amount)
        end

        @existing_settlements = @reimbursement.settlements.for_shipment.not_pending
      end

      def attempt_accept_new_settlements
        @reimbursement.settlements.pending.each do |settlement|
          settlement.attempt_accept!
        end
      end

      def load_simulated_refunds
        @reimbursement_objects = @reimbursement.simulate
      end

      def spree_core_gateway_error(error)
        flash[:error] = error.message
        redirect_to edit_admin_order_reimbursement_path(parent, @reimbursement)
      end

      def render_after_update_error
        redirect_back(fallback_location: location_after_save,
                      flash: { error: @object.errors.full_messages.join(', ') })
      end
    end
  end
end
