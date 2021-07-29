# frozen_string_literal: true

module Spree
  module Event
    # Registry of known events
    #
    # @api privte
    class Registry
      class Registration
        attr_reader :event_name, :caller_location

        def initialize(event_name:, caller_location:)
          @event_name = event_name
          @caller_location = caller_location
        end
      end

      attr_reader :registrations

      def initialize(registrations: [])
        @registrations = registrations
      end

      def register(event_name, caller_location: caller_locations(1)[0])
        registration = registration(event_name)
        if registration
          raise <<~MSG
            Can't register #{event_name} event as it's already registered.

            The registration happened at:

            #{registration.caller_location}
          MSG
        else
          @registrations << Registration.new(event_name: event_name, caller_location: caller_location)
        end
      end

      def unregister(event_name)
        raise <<~MSG unless registered?(event_name)
          #{event_name} is not registered.

          Known events are:

            '#{event_names.join("' '")}'
        MSG

        @registrations.delete_if { |regs| regs.event_name == event_name }
      end

      def registration(event_name)
        registrations.find { |reg| reg.event_name == event_name }
      end

      def registered?(event_name)
        !registration(event_name).nil?
      end

      def event_names
        registrations.map(&:event_name)
      end

      def check_event_name_registered(event_name)
        return true if registered?(event_name)

        raise <<~MSG
            '#{event_name}' is not registered as a valid event name.
            #{suggestions_message(event_name)}

            All known events are:

              '#{event_names.join(" ")}'

            You can register the new events at the end of the `spree.rb`
            initializer:

              Spree::Event.register('#{event_name}')
        MSG
      end

      private

      def suggestions(event_name)
        dictionary = DidYouMean::SpellChecker.new(dictionary: event_names)

        dictionary.correct(event_name)
      end

      def suggestions_message(event_name)
        DidYouMean::PlainFormatter.new.message_for(suggestions(event_name))
      end
    end
  end
end
