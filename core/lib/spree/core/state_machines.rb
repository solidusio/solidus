# frozen_string_literal: true

module Spree
  module Core
    class StateMachines < Spree::Preferences::Configuration
      # State Machine module for Reimbursements
      #
      # @!attribute [rw] reimbursement
      # @return [Module] a module that implements the state machine for the `Spree::Reimbursement` model.
      class_name_attribute :reimbursement, default: "Spree::Core::StateMachines::Reimbursement"

      # State Machine module for Return Authorizations
      #
      # @!attribute [rw] return_authorization
      # @return [Module] a module that implements the state machine for the `Spree::ReturnAuthorization` model.
      class_name_attribute :return_authorization, default: "Spree::Core::StateMachines::ReturnAuthorization"

      # State Machine module for Return Item Acceptances
      #
      # @!attribute [rw] return_item_acceptance
      # @return [Module] a module that implements the acceptance part of the state machine for the `Spree::ReturnItem` model.
      class_name_attribute :return_item_acceptance, default: "Spree::Core::StateMachines::ReturnItem::AcceptanceStatus"

      # State Machine module for Return Item Receptions
      #
      # @!attribute [rw] return_item_reception
      # @return [Module] a module that implements the reception part of the state machine for the `Spree::ReturnItem` model.
      class_name_attribute :return_item_reception, default: "Spree::Core::StateMachines::ReturnItem::ReceptionStatus"

      # State Machine module for Payments
      #
      # @!attribute [rw] payment
      # @return [Module] a module that implements the state machine for the `Spree::Payment` model.
      class_name_attribute :payment, default: "Spree::Core::StateMachines::Payment"

      # State Machine module for Inventory Units
      #
      # @!attribute [rw] inventory_unit
      # @return [Module] a module that implements the state machine for the `Spree::InventoryUnit` model.
      class_name_attribute :inventory_unit, default: "Spree::Core::StateMachines::InventoryUnit"

      # State Machine module for Shipments
      #
      # @!attribute [rw] shipment
      # @return [Module] a module that implements the state machine for the `Spree::Shipment` model.
      class_name_attribute :shipment, default: "Spree::Core::StateMachines::Shipment"

      # State Machine module for Orders
      #
      # @!attribute [rw] order
      # @return [Module] a module that implements the state machine for the `Spree::Order` model.
      class_name_attribute :order, default: "Spree::Core::StateMachines::Order"
    end
  end
end
