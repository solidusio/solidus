# frozen_string_literal: true

module Spree
  # Configurable class to enqueue state change tracking jobs
  # Configure your custom logic by setting Spree::Config.state_change_tracking_class
  # @example Spree::Config.state_change_tracking_class = MyCustomTracker
  class StateChangeTracker
    # @param stateful [Object] The stateful object to track changes for
    # @param previous_state [String] The previous state of the order
    # @param current_state [String] The current state of the order
    # @param transition_timestamp [Time] When the state transition occurred
    # @param stateful_name [String] The element name of the state transition being
    #   tracked. It defaults to the `stateful` model element name.
    def self.call(
      stateful:,
      previous_state:,
      current_state:,
      transition_timestamp:,
      stateful_name: stateful.class.model_name.element
    )
      # Enqueue a background job to track this state change
      StateChangeTrackingJob.perform_later(
        stateful,
        previous_state,
        current_state,
        transition_timestamp,
        stateful_name
      )
    end
  end
end
