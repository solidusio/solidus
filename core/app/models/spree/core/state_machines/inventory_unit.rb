# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      # Inventory Units' state machine
      #
      # for each event the following instance methods are dynamically implemented:
      #   #<event_name>
      #   #<event_name>!
      #   #can_<event_name>?
      #
      # for each state the following instance methods are implemented:
      #   #<state_name>?
      #
      module InventoryUnit
        extend ActiveSupport::Concern

        included do
          state_machine initial: :on_hand do
            event :fill_backorder do
              transition to: :on_hand, from: :backordered
            end
            after_transition on: :fill_backorder, do: :fulfill_order

            event :ship do
              transition to: :shipped, if: :allow_ship?
            end

            event :return do
              transition to: :returned, from: :shipped
            end

            event :cancel do
              transition to: :canceled, from: ::Spree::InventoryUnit::CANCELABLE_STATES.map(&:to_sym)
            end
          end
        end
      end
    end
  end
end
