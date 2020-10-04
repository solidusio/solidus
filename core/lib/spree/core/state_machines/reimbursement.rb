# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      # Reimbursement' state machine
      #
      # for each event the following instance methods are dynamically implemented:
      #   #<event_name>
      #   #<event_name>!
      #   #can_<event_name>?
      #
      # for each state the following instance methods are implemented:
      #   #<state_name>?
      #
      module Reimbursement
        extend ActiveSupport::Concern

        included do
          state_machine :reimbursement_status, initial: :pending do
            event :errored do
              transition to: :errored, from: [:pending, :errored]
            end

            event :reimbursed do
              transition to: :reimbursed, from: [:pending, :errored]
            end
          end
        end
      end
    end
  end
end
