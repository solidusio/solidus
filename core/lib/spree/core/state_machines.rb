# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      attr_writer :reimbursement,
                  :return_authorization,
                  :return_item_acceptance,
                  :return_item_reception,
                  :payment,
                  :inventory_unit,
                  :shipment

      def return_authorization
        @return_authorization ||= begin
          require 'spree/core/state_machines/return_authorization'
          'Spree::Core::StateMachines::ReturnAuthorization'
        end

        @return_authorization.constantize
      end

      def return_item_reception
        @return_item_reception_status ||= begin
          require 'spree/core/state_machines/return_item/reception_status'
          'Spree::Core::StateMachines::ReturnItem::ReceptionStatus'
        end

        @return_item_reception_status.constantize
      end

      def return_item_acceptance
        @return_item_acceptance_status ||= begin
          require 'spree/core/state_machines/return_item/acceptance_status'
          'Spree::Core::StateMachines::ReturnItem::AcceptanceStatus'
        end

        @return_item_acceptance_status.constantize
      end

      def payment
        @payment ||= begin
          require 'spree/core/state_machines/payment'
          'Spree::Core::StateMachines::Payment'
        end

        @payment.constantize
      end

      def inventory_unit
        @inventory_unit ||= begin
          require 'spree/core/state_machines/inventory_unit'
          'Spree::Core::StateMachines::InventoryUnit'
        end

        @inventory_unit.constantize
      end

      def shipment
        @shipment ||= begin
          require 'spree/core/state_machines/shipment'
          'Spree::Core::StateMachines::Shipment'
        end

        @shipment.constantize
      end

      def reimbursement
        @reimbursement ||= begin
          require 'spree/core/state_machines/reimbursement'
          'Spree::Core::StateMachines::Reimbursement'
        end

        @reimbursement.constantize
      end
    end
  end
end
