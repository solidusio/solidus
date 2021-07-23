# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      # Payments' state machine
      #
      # for each event the following instance methods are dynamically implemented:
      #   #<event_name>
      #   #<event_name>!
      #   #can_<event_name>?
      #
      # for each state the following instance methods are implemented:
      #   #<state_name>?
      #
      module Payment
        extend ActiveSupport::Concern

        included do
          state_machine initial: :checkout do
            # With card payments, happens before purchase or authorization happens
            #
            # Setting it after creating a profile and authorizing a full amount will
            # prevent the payment from being authorized again once Order transitions
            # to complete
            event :started_processing do
              transition from: [:checkout, :pending, :completed, :processing], to: :processing
            end
            # When processing during checkout fails
            event :failure do
              transition from: [:pending, :processing], to: :failed
            end
            # With card payments this represents authorizing the payment
            event :pend do
              transition from: [:checkout, :processing], to: :pending
            end
            # With card payments this represents completing a purchase or capture transaction
            event :complete do
              transition from: [:processing, :pending, :checkout], to: :completed
            end
            event :void do
              transition from: [:pending, :processing, :completed, :checkout], to: :void
            end
            # when the card brand isnt supported
            event :invalidate do
              transition from: [:checkout], to: :invalid
            end

            after_transition do |payment, transition|
              payment.state_changes.create!(
                previous_state: transition.from,
                next_state:     transition.to,
                name:           'payment'
              )
              Spree::Event.fire "payment_transitioned_to_#{transition.to}", payment: payment
              payment.logger.debug "Payment #{payment.number} transitioned from #{transition.from} to #{transition.to} via #{transition.event}"
            end

            after_failure do |payment, transition|
              Spree::Event.fire "payment_failed_transition_to_#{transition.to}", payment: payment
              payment.logger.debug "Payment #{payment.number} halted transition on event #{transition.event} state #{transition.from}: #{payment.errors.full_messages.join}"
            end
          end
        end
      end
    end
  end
end
