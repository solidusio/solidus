# frozen_string_literal: true

module Spree
  module Event
    class SubscriberRegistry
      def initialize
        @registry = {}
        @semaphore = Mutex.new
      end

      def register(subscriber)
        registry[subscriber.name] ||= {}
      end

      def activate_autoloadable_subscribers
        require_subscriber_files
        activate_all_subscribers
      end

      def activate_all_subscribers
        registry.each_key { |subscriber_name| activate_subscriber(subscriber_name.constantize) }
      end

      def deactivate_all_subscribers
        registry.each_key { |subscriber_name| deactivate_subscriber(subscriber_name.constantize) }
      end

      def activate_subscriber(subscriber)
        return unless registry[subscriber.name]

        subscriber.event_actions.each do |event_action, event_name|
          @semaphore.synchronize do
            unsafe_deactivate_subscriber(subscriber, event_action)

            subscription = Spree::Event.subscribe(event_name) { |event| subscriber.send(event_action, event) }

            # deprecated mappings, to be removed when Solidus 2.10 is not supported anymore:
            subscriber.send("#{event_action}_handler=", subscription)

            registry[subscriber.name][event_action] = subscription
          end
        end
      end

      def deactivate_subscriber(subscriber, event_action_name = nil)
        @semaphore.synchronize do
          unsafe_deactivate_subscriber(subscriber, event_action_name)
        end
      end

      private

      attr_reader :registry

      # Loads all Solidus' core and application's event subscribers files.
      # The latter are loaded automatically only when the preference
      # Spree::Config.events.autoload_subscribers is set to a truthy value.
      #
      # Files must be placed under the directory `app/subscribers` and their
      # name must end with `_subscriber.rb`.
      #
      # Loading the files has the side effect of adding their module to the
      # list in Spree::Event.subscribers.
      def require_subscriber_files
        pattern = "app/subscribers/**/*_subscriber.rb"

        # Load Solidus subscribers
        # rubocop:disable Rails/DynamicFindBy
        solidus_core_dir = Gem::Specification.find_by_name('solidus_core').gem_dir
        # rubocop:enable Rails/DynamicFindBy
        Dir.glob(File.join(solidus_core_dir, pattern)) { |c| require_dependency(c.to_s) }

        # Load application subscribers, only when the flag is set to true:
        if Spree::Config.events.autoload_subscribers
          Rails.root.glob(pattern) { |c| require_dependency(c.to_s) }
        end
      end

      def unsafe_deactivate_subscriber(subscriber, event_action_name = nil)
        to_unsubscribe = Array.wrap(event_action_name || subscriber.event_actions.keys)

        to_unsubscribe.each do |event_action|
          if (subscription = registry.dig(subscriber.name, event_action))
            Spree::Event.unsubscribe(subscription)

            registry[subscriber.name].delete(event_action)
          end
        end
      end
    end
  end
end
