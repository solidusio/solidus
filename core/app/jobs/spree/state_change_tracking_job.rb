# frozen_string_literal: true

module Spree
  # Background job to track state changes asynchronously
  # This avoids performance impact during checkout and prevents
  # callback-related issues with recent versions of the state_machines gem.
  class StateChangeTrackingJob < BaseJob
    # @param stateful [GlobalId] The stateful object to track changes for
    # @param previous_state [String] The previous state of the order
    # @param current_state [String] The current state of the order
    # @param transition_timestamp [Time] When the state transition occurred
    # @param name [String] The element name of the state transition being
    #   tracked. It defaults to the `stateful` model element name.
    def perform(
      stateful,
      previous_state,
      current_state,
      transition_timestamp,
      name = stateful.class.model_name.element
    )
      Spree::StateChange.create!(
        name: name,
        stateful: stateful,
        previous_state: previous_state,
        next_state: current_state,
        created_at: transition_timestamp,
        updated_at: transition_timestamp,
        user_id: stateful.try(:user_id) || stateful.try(:order)&.user_id
      )
    end
  end
end
