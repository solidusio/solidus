# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      module ReturnItem
        # Return Items' acceptance status state machine
        #
        # for each event the following instance methods are dynamically implemented:
        #   #<event_name>
        #   #<event_name>!
        #   #can_<event_name>?
        #
        # for each state the following instance methods are implemented:
        #   #<state_name>?
        #
        module AcceptanceStatus
          extend ActiveSupport::Concern

          included do
            state_machine :acceptance_status, initial: :pending do
              event :attempt_accept do
                transition to: :accepted, from: :accepted
                transition to: :accepted, from: :pending, if: ->(return_item) { return_item.eligible_for_return? }
                transition to: :manual_intervention_required, from: :pending, if: ->(return_item) { return_item.requires_manual_intervention? }
                transition to: :rejected, from: :pending
              end

              # bypasses eligibility checks
              event :accept do
                transition to: :accepted, from: [:accepted, :pending, :manual_intervention_required]
              end

              # bypasses eligibility checks
              event :reject do
                transition to: :rejected, from: [:accepted, :pending, :manual_intervention_required]
              end

              # bypasses eligibility checks
              event :require_manual_intervention do
                transition to: :manual_intervention_required, from: [:accepted, :pending, :manual_intervention_required]
              end

              after_transition any => any, do: :persist_acceptance_status_errors
            end
          end
        end
      end
    end
  end
end
