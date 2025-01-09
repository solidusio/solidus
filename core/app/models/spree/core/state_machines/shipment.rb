# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      # Shipments' state machine
      #
      # for each event the following instance methods are dynamically implemented:
      #   #<event_name>
      #   #<event_name>!
      #   #can_<event_name>?
      #
      # for each state the following instance methods are implemented:
      #   #<state_name>?
      #
      module Shipment
        extend ActiveSupport::Concern

        included do
          state_machine initial: :pending, use_transactions: false do
            event :ready do
              transition from: :pending, to: :shipped, if: :can_transition_from_pending_to_shipped?
              transition from: :pending, to: :ready, if: :can_transition_from_pending_to_ready?
            end

            event :pend do
              transition from: :ready, to: :pending
            end

            event :ship do
              transition from: [:ready, :canceled], to: :shipped
            end
            after_transition to: :shipped, do: :after_ship

            event :cancel do
              transition to: :canceled, from: [:pending, :ready]
            end
            after_transition to: :canceled, do: :after_cancel

            event :resume do
              transition from: :canceled, to: :ready, if: :can_transition_from_canceled_to_ready?
              transition from: :canceled, to: :pending
            end
            after_transition from: :canceled, to: [:pending, :ready, :shipped], do: :after_resume

            after_transition do |shipment, transition|
              shipment.state_changes.create!(
                previous_state: transition.from,
                next_state:     transition.to,
                name:           'shipment'
              )
            end
          end
        end
      end
    end
  end
end
