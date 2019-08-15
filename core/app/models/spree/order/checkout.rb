# frozen_string_literal: true

module Spree
  class Order < Spree::Base
    module Checkout
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        attr_accessor :previous_states
        attr_writer :next_event_transitions
        attr_writer :checkout_steps
        attr_writer :removed_transitions

        def checkout_flow(&block)
          if block_given?
            @checkout_flow = block
            define_state_machine!
          else
            @checkout_flow
          end
        end

        def define_state_machine!
          self.checkout_steps = {}
          self.next_event_transitions = []
          self.previous_states = [:cart]
          self.removed_transitions = []

          # Build the checkout flow using the checkout_flow defined either
          # within the Order class, or a decorator for that class.
          #
          # This method may be called multiple times depending on if the
          # checkout_flow is re-defined in a decorator or not.
          instance_eval(&checkout_flow)

          klass = self

          # To avoid multiple occurrences of the same transition being defined
          # On first definition, state_machines will not be defined
          state_machines.clear if respond_to?(:state_machines)
          state_machine :state, initial: :cart, use_transactions: false do
            klass.next_event_transitions.each { |state| transition(state.merge(on: :next)) }

            # Persist the state on the order
            after_transition do |order, transition|
              order.state = order.state
              order.state_changes.create(
                previous_state: transition.from,
                next_state:     transition.to,
                name:           'order',
                user_id:        order.user_id
              )
              order.save
            end

            event :cancel do
              transition to: :canceled, if: :allow_cancel?
            end

            event :return do
              transition to: :returned, from: [:returned, :complete, :awaiting_return, :canceled], if: :all_inventory_units_returned?
            end

            event :resume do
              transition to: :resumed, from: :canceled, if: :canceled?
            end

            event :authorize_return do
              transition to: :awaiting_return
            end

            event :complete do
              transition to: :complete, from: :confirm
            end

            if states[:payment]
              event :payment_failed do
                transition to: :payment, from: :confirm
              end

              after_transition to: :complete, do: :add_payment_sources_to_wallet
              before_transition to: :payment, do: :add_default_payment_from_wallet

              before_transition to: :confirm, do: :add_store_credit_payments

              # see also process_payments_before_complete below which needs to
              # be added in the correct sequence.
            end

            before_transition from: :cart, do: :ensure_line_items_present

            if states[:address]
              before_transition to: :address, do: :assign_default_user_addresses
              before_transition from: :address, do: :persist_user_address!
            end

            if states[:delivery]
              before_transition to: :delivery, do: :ensure_shipping_address
              before_transition to: :delivery, do: :create_proposed_shipments
              before_transition to: :delivery, do: :ensure_available_shipping_rates
              before_transition from: :delivery, do: :apply_shipping_promotions
            end

            before_transition to: :resumed, do: :ensure_line_item_variants_are_not_deleted
            before_transition to: :resumed, do: :validate_line_item_availability

            # Sequence of before_transition to: :complete
            # calls matter so that we do not process payments
            # until validations have passed
            before_transition to: :complete, do: :validate_line_item_availability
            before_transition to: :complete, do: :ensure_promotions_eligible
            before_transition to: :complete, do: :ensure_line_item_variants_are_not_deleted
            before_transition to: :complete, do: :ensure_inventory_units
            if states[:payment]
              before_transition to: :complete, do: :process_payments_before_complete
            end

            after_transition to: :complete, do: :finalize!
            after_transition to: :resumed,  do: :after_resume
            after_transition to: :canceled, do: :after_cancel

            after_transition from: any - :cart, to: any - [:confirm, :complete] do |order|
              order.recalculate
            end

            after_transition do |order, transition|
              order.logger.debug "Order #{order.number} transitioned from #{transition.from} to #{transition.to} via #{transition.event}"
            end

            after_failure do |order, transition|
              order.logger.debug "Order #{order.number} halted transition on event #{transition.event} state #{transition.from}: #{order.errors.full_messages.join}"
            end
          end
        end

        def go_to_state(name, options = {})
          checkout_steps[name] = options
          previous_states.each do |state|
            add_transition({ from: state, to: name }.merge(options))
          end
          if options[:if]
            previous_states << name
          else
            self.previous_states = [name]
          end
        end

        def insert_checkout_step(name, options = {})
          before = options.delete(:before)
          after = options.delete(:after) unless before
          after = checkout_steps.keys.last unless before || after

          cloned_steps = checkout_steps.clone
          cloned_removed_transitions = removed_transitions.clone
          checkout_flow do
            cloned_steps.each_pair do |key, value|
              go_to_state(name, options) if key == before
              go_to_state(key, value)
              go_to_state(name, options) if key == after
            end
            cloned_removed_transitions.each do |transition|
              remove_transition(transition)
            end
          end
        end

        def remove_checkout_step(name)
          cloned_steps = checkout_steps.clone
          cloned_removed_transitions = removed_transitions.clone
          checkout_flow do
            cloned_steps.each_pair do |key, value|
              go_to_state(key, value) unless key == name
            end
            cloned_removed_transitions.each do |transition|
              remove_transition(transition)
            end
          end
        end

        def remove_transition(options = {})
          removed_transitions << options
          next_event_transitions.delete(find_transition(options))
        end

        def find_transition(options = {})
          return nil if options.nil? || !options.include?(:from) || !options.include?(:to)
          next_event_transitions.detect do |transition|
            transition[options[:from].to_sym] == options[:to].to_sym
          end
        end

        def next_event_transitions
          @next_event_transitions ||= []
        end

        def checkout_steps
          @checkout_steps ||= {}
        end

        def checkout_step_names
          checkout_steps.keys
        end

        def add_transition(options)
          next_event_transitions << { options.delete(:from) => options.delete(:to) }.merge(options)
        end

        def removed_transitions
          @removed_transitions ||= []
        end
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
