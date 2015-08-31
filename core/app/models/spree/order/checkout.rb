module Spree
  class Order < Spree::Base
    module Checkout
      def self.included(klass)
        klass.class_eval do
          class_attribute :next_event_transitions
          class_attribute :previous_states
          class_attribute :checkout_flow
          class_attribute :checkout_steps
          class_attribute :removed_transitions

          def self.checkout_flow(&block)
            if block_given?
              @checkout_flow = block
              define_state_machine!
            else
              @checkout_flow
            end
          end

          def self.define_state_machine!
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
            state_machine :state, initial: :cart, use_transactions: false, action: :save_state do
              klass.next_event_transitions.each { |t| transition(t.merge(on: :next)) }

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

                after_transition to: :complete, do: :persist_user_credit_card
                before_transition to: :payment, do: :set_shipments_cost
                before_transition to: :payment, do: :create_tax_charge!
                before_transition to: :payment, do: :assign_default_credit_card

                before_transition to: :confirm, do: :add_store_credit_payments

                # see also process_payments_before_complete below which needs to
                # be added in the correct sequence.
              end

              before_transition from: :cart, do: :ensure_line_items_present

              if states[:address]
                before_transition from: :address, do: :create_tax_charge!
                before_transition to: :address, do: :assign_default_addresses!
                before_transition from: :address, do: :persist_user_address!
              end

              if states[:delivery]
                before_transition to: :delivery, do: :ensure_shipping_address
                before_transition to: :delivery, do: :create_proposed_shipments
                before_transition to: :delivery, do: :ensure_available_shipping_rates
                before_transition to: :delivery, do: :set_shipments_cost
                before_transition from: :delivery, do: :apply_free_shipping_promotions
              end

              before_transition to: :resumed, do: :ensure_line_item_variants_are_not_deleted
              before_transition to: :resumed, do: :validate_line_item_availability

              # Sequence of before_transition to: :complete
              # calls matter so that we do not process payments
              # until validations have passed
              before_transition to: :complete, do: :validate_line_item_availability, unless: :unreturned_exchange?
              before_transition to: :complete, do: :ensure_available_shipping_rates
              before_transition to: :complete, do: :ensure_promotions_eligible
              before_transition to: :complete, do: :ensure_line_item_variants_are_not_deleted
              before_transition to: :complete, do: :ensure_inventory_units, unless: :unreturned_exchange?
              if states[:payment]
                before_transition to: :complete, do: :process_payments_before_complete
              end

              after_transition to: :complete, do: :finalize!
              after_transition to: :resumed,  do: :after_resume
              after_transition to: :canceled, do: :after_cancel

              after_transition from: any - :cart, to: any - [:confirm, :complete] do |order|
                order.update_totals
                order.persist_totals
              end
            end

            alias_method :save_state, :save
          end

          def self.go_to_state(name, options={})
            self.checkout_steps[name] = options
            previous_states.each do |state|
              add_transition({from: state, to: name}.merge(options))
            end
            if options[:if]
              self.previous_states << name
            else
              self.previous_states = [name]
            end
          end

          def self.insert_checkout_step(name, options = {})
            before = options.delete(:before)
            after = options.delete(:after) unless before
            after = self.checkout_steps.keys.last unless before || after

            cloned_steps = self.checkout_steps.clone
            cloned_removed_transitions = self.removed_transitions.clone
            self.checkout_flow do
              cloned_steps.each_pair do |key, value|
                self.go_to_state(name, options) if key == before
                self.go_to_state(key, value)
                self.go_to_state(name, options) if key == after
              end
              cloned_removed_transitions.each do |transition|
                self.remove_transition(transition)
              end
            end
          end

          def self.remove_checkout_step(name)
            cloned_steps = self.checkout_steps.clone
            cloned_removed_transitions = self.removed_transitions.clone
            self.checkout_flow do
              cloned_steps.each_pair do |key, value|
                self.go_to_state(key, value) unless key == name
              end
              cloned_removed_transitions.each do |transition|
                self.remove_transition(transition)
              end
            end
          end

          def self.remove_transition(options={})
            self.removed_transitions << options
            self.next_event_transitions.delete(find_transition(options))
          end

          def self.find_transition(options={})
            return nil if options.nil? || !options.include?(:from) || !options.include?(:to)
            self.next_event_transitions.detect do |transition|
              transition[options[:from].to_sym] == options[:to].to_sym
            end
          end

          def self.next_event_transitions
            @next_event_transitions ||= []
          end

          def self.checkout_steps
            @checkout_steps ||= {}
          end

          def self.checkout_step_names
            self.checkout_steps.keys
          end

          def self.add_transition(options)
            self.next_event_transitions << { options.delete(:from) => options.delete(:to) }.merge(options)
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
            step.present? && self.checkout_steps.include?(step)
          end

          def passed_checkout_step?(step)
            has_checkout_step?(step) && checkout_step_index(step) < checkout_step_index(self.state)
          end

          def checkout_step_index(step)
            self.checkout_steps.index(step).to_i
          end

          def self.removed_transitions
            @removed_transitions ||= []
          end

          def can_go_to_state?(state)
            return false unless has_checkout_step?(self.state) && has_checkout_step?(state)
            checkout_step_index(state) > checkout_step_index(self.state)
          end

          def update_from_params(attributes, request_env: {})
            if attributes[:payments_attributes]
              attributes[:payments_attributes].each do |payment_attributes|
                payment_attributes[:request_env] = request_env
              end
            end

            if update_attributes(attributes)
              set_shipments_cost if self.shipments.any?
              true
            else
              false
            end
          end

          def bill_address_attributes=(attributes)
            self.bill_address = Address.immutable_merge(bill_address, attributes)
          end

          def ship_address_attributes=(attributes)
            self.ship_address = Address.immutable_merge(ship_address, attributes)
          end

          def assign_default_addresses!
            if self.user
              # this is one of 2 places still using User#bill_address
              self.bill_address ||= user.bill_address if user.bill_address.try!(:valid?)
              # Skip setting ship address if order doesn't have a delivery checkout step
              # to avoid triggering validations on shipping address
              self.ship_address ||= user.ship_address if user.ship_address.try!(:valid?) && self.checkout_steps.include?("delivery")
            end
          end

          def persist_user_address!
            if !self.temporary_address && self.user && self.user.respond_to?(:persist_order_address) && self.bill_address_id
              self.user.persist_order_address(self)
            end
          end

          def persist_user_credit_card
            if !self.temporary_credit_card && self.user_id && self.valid_credit_cards.present?
              default_cc = self.valid_credit_cards.first
              # TODO target for refactoring -- why is order checkout responsible for the user -> credit_card relationship?
              default_cc.user_id = self.user_id
              default_cc.default = true
              default_cc.save
            end
          end

          def assign_default_credit_card
            if self.payments.from_credit_card.count == 0 && self.user && self.user.default_credit_card.try(:valid?)
              cc = self.user.default_credit_card
              self.payments.create!(payment_method_id: cc.payment_method_id, source: cc)
              # this is one of 2 places still using User#bill_address
              self.bill_address ||= user.default_credit_card.address || user.bill_address
            end
          end

          private

          def process_payments_before_complete
            return if !payment_required?

            if payments.valid.empty?
              errors.add(:base, Spree.t(:no_payment_found))
              return false
            end

            if process_payments!
              true
            else
              saved_errors = errors[:base]
              payment_failed!
              saved_errors.each { |error| errors.add(:base, error) }
              false
            end
          end

        end
      end
    end
  end
end
