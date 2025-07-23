# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      module Order
        def self.included(klass)
          klass.extend ClassMethods
          klass.include StateChangeTracking
        end

        def checkout_steps
          steps = self.class.checkout_steps.each_with_object([]) { |(step, options), checkout_steps|
            next if options.include?(:if) && !options[:if].call(self)

            checkout_steps << step
          }.map(&:to_s)
          # Ensure there is always a complete step
          steps << "complete" unless steps.include?("complete")
          steps
        end

        def has_checkout_step?(step)
          step.present? && checkout_steps.include?(step)
        end

        def passed_checkout_step?(step)
          has_checkout_step?(step) && checkout_step_index(step) < checkout_step_index(state)
        end

        def checkout_step_index(step)
          checkout_steps.index(step).to_i
        end

        def can_go_to_state?(state)
          return false unless has_checkout_step?(self.state) && has_checkout_step?(state)

          checkout_step_index(state) > checkout_step_index(self.state)
        end
      end
    end
  end
end
