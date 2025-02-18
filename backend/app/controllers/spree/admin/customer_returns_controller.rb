# frozen_string_literal: true

module Spree
  module Admin
    class CustomerReturnsController < ResourceController
      helper "spree/admin/reimbursement_type"
      belongs_to "spree/order", find_by: :number

      before_action :parent # ensure order gets loaded to support our pseudo parent-child relationship
      before_action :load_form_data, only: [:new, :edit]
      before_action :build_return_items_from_params, only: [:create]
      create.fails :load_form_data
      create.after :order_process_return

      def edit
        @pending_return_items = @customer_return.return_items.select(&:pending?)
        @accepted_return_items = @customer_return.return_items.select(&:accepted?)
        @rejected_return_items = @customer_return.return_items.select(&:rejected?)
        @manual_intervention_return_items = @customer_return.return_items.select(&:manual_intervention_required?)
        @pending_reimbursements = @customer_return.reimbursements.select(&:pending?)

        super
      end

      private

      def order_process_return
        @customer_return.process_return!
      end

      def location_after_save
        url_for([:edit, :admin, @order, @customer_return])
      end

      def build_resource
        Spree::CustomerReturn.new
      end

      def find_resource
        Spree::CustomerReturn.accessible_by(current_ability, :show).find(params[:id])
      end

      def collection
        parent # trigger loading the order
        return unless @order

        @collection ||= Spree::ReturnItem
          .accessible_by(current_ability)
          .where(inventory_unit_id: @order.inventory_units.pluck(:id))
          .map(&:customer_return).uniq.compact
        @customer_returns = @collection
      end

      def load_form_data
        return_items = @order.inventory_units.map(&:current_or_new_return_item).reject(&:customer_return_id)
        @rma_return_items, @new_return_items = return_items.partition(&:return_authorization_id)
        load_return_reasons
      end

      def load_return_reasons
        @reasons = Spree::ReturnReason.reasons_for_return_items(@customer_return.return_items)
      end

      def permitted_resource_params
        @permitted_resource_params ||= params.require("customer_return").permit(permitted_customer_return_attributes)
      end

      def build_return_items_from_params
        return_items_params = permitted_resource_params.delete(:return_items_attributes).values
        @customer_return.return_items = return_items_params.map do |item_params|
          next unless item_params.delete("returned") == "1"
          return_item = item_params[:id] ? Spree::ReturnItem.find(item_params[:id]) : Spree::ReturnItem.new
          return_item.assign_attributes(item_params)

          if item_params[:reception_status_event].blank?
            return redirect_to(new_object_url, flash: {error: "Reception status choice required"})
          end
          return_item
        end.compact
      end
    end
  end
end
