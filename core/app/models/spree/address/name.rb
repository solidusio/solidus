# frozen_string_literal: true

module Spree
  class Address
    # Provides a value object to help splitting and joining
    # name fields
    class Name
      attr_reader :first_name, :last_name, :value

      def initialize(*components)
        @value = components.join(' ').strip
        initialize_name_components(components)
      end

      def to_s
        @value
      end

      private

      def initialize_name_components(components)
        if components.size == 2
          @first_name = components[0].to_s
          @last_name = components[1].to_s
        else
          @first_name, @last_name = @value.split(/[[:space:]]/, 2)
        end
      end
    end
  end
end

