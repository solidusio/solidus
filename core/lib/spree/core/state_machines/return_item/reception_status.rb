# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      module ReturnItem
        # Return Items' reception status state machine
        #
        # for each event the following instance methods are dynamically implemented:
        #   #<event_name>
        #   #<event_name>!
        #   #can_<event_name>?
        #
        # for each state the following instance methods are implemented:
        #   #<state_name>?
        #
        module ReceptionStatus
          extend ActiveSupport::Concern

          included do
            state_machine :reception_status, initial: :awaiting do
              after_transition to: ::Spree::ReturnItem::COMPLETED_RECEPTION_STATUSES, do: :attempt_accept, if: :can_attempt_accept?
              after_transition to: ::Spree::ReturnItem::COMPLETED_RECEPTION_STATUSES, do: :check_unexchange
              after_transition to: :received, do: :process_inventory_unit!

              event(:cancel) { transition to: :cancelled, from: :awaiting }

              event(:receive) { transition to: :received, from: ::Spree::ReturnItem::INTERMEDIATE_RECEPTION_STATUSES + [:awaiting] }
              event(:unexchange) { transition to: :unexchanged, from: [:awaiting] }
              event(:give) { transition to: :given_to_customer, from: :awaiting }
              event(:lost) { transition to: :lost_in_transit, from: :awaiting }
              event(:wrong_item_shipped) { transition to: :shipped_wrong_item, from: :awaiting }
              event(:short_shipped) { transition to: :short_shipped, from: :awaiting }
              event(:in_transit) { transition to: :in_transit, from: :awaiting }
              event(:expired) { transition to: :expired, from: :awaiting }
            end
          end
        end
      end
    end
  end
end
