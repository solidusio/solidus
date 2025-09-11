# frozen_string_literal: true

# Simple shorthands and helpers for stimulus data attributes to avoid writing clumsy interpolations with `stimulus_id`
#  Before: "data-#{stimulus_id}-target": "wrapper"
#  After: stimulus_target("wrapper")

module SolidusAdmin
  module StimulusHelper
    def stimulus_controller
      {"data-controller": stimulus_id}
    end

    def stimulus_action(action, on: nil)
      action_construct = []
      action_construct << "#{on}->" if on.present?
      action_construct << "#{stimulus_id}##{action}"

      {"data-action": action_construct.join}
    end

    def stimulus_target(target)
      {"data-#{stimulus_id}-target": target}
    end

    def stimulus_value(name:, value:)
      {"data-#{stimulus_id}-#{name}-value": value}
    end
  end
end
