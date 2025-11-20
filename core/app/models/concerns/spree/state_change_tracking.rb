# frozen_string_literal: true

module Spree
  module StateChangeTracking
    extend ActiveSupport::Concern

    included do
      after_update :enqueue_state_change_tracking, if: :saved_change_to_state?
    end

    private

    # Enqueue background job to track state changes asynchronously
    def enqueue_state_change_tracking
      previous_state, current_state = saved_changes['state']

      # Enqueue the job to track this state change
      Spree::Config.state_change_tracking_class.call(
        stateful: self,
        previous_state:,
        current_state:,
        transition_timestamp: Time.current
      )
    end
  end
end
