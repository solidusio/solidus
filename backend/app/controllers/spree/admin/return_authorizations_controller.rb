# frozen_string_literal: true

module Spree
  module Admin
    class ReturnAuthorizationsController < ResourceController
      belongs_to 'spree/order', find_by: :number

      before_action :load_form_data, only: [:new, :edit]
      create.fails  :load_form_data
      update.fails  :load_form_data

      def fire
        action_from_params = "#{params[:e]}!"

        if @return_authorization.state_events.include?(params[:e].to_sym) &&
           @return_authorization.send(action_from_params)

          flash_message = { success: t('spree.return_authorization_updated') }
        else
          flash_message = { error: t('spree.return_authorization_fire_error') }
        end

        redirect_back(fallback_location: admin_order_return_authorizations_path(@order),
                      flash: flash_message)
      end

      private

      def load_form_data
        load_return_items
        load_reimbursement_types
        load_return_reasons
        load_stock_locations
      end

      # To satisfy how nested attributes works we want to create placeholder ReturnItems for
      # any InventoryUnits that have not already been added to the ReturnAuthorization.
      def load_return_items
        all_inventory_units = @return_authorization.order.inventory_units
        associated_inventory_units = @return_authorization.return_items.map(&:inventory_unit)
        unassociated_inventory_units = all_inventory_units - associated_inventory_units

        new_return_items = unassociated_inventory_units.map do |new_unit|
          Spree::ReturnItem.new(inventory_unit: new_unit).tap(&:set_default_amount)
        end
        @form_return_items = (@return_authorization.return_items + new_return_items).sort_by(&:inventory_unit_id)
      end

      def load_reimbursement_types
        @reimbursement_types = Spree::ReimbursementType.accessible_by(current_ability, :read).active
      end

      def load_return_reasons
        @reasons = Spree::ReturnReason.reasons_for_return_items(@return_authorization.return_items)
      end

      def load_stock_locations
        @stock_locations = Spree::StockLocation.order_default.active
      end
    end
  end
end
