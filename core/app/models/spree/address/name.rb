# frozen_string_literal: true

module Spree
  class Address
    # Provides a value object to help transitioning from legacy
    # firstname and lastname fields to a unified name field.
    class Name
      attr_reader :first_name, :last_name, :value

      # Creates an instance of Spree::Address::Name parsing input attributes.
      # @param attributes [Hash] an hash possibly containing name-related
      #   attributes (name, firstname, lastname, first_name, last_name)
      # @return [Spree::Address::Name] the object created
      def self.from_attributes(attributes)
        params = attributes.with_indifferent_access

        if params[:name].present?
          Spree::Address::Name.new(params[:name])
        elsif params[:firstname].present?
          Spree::Address::Name.new(params[:firstname], params[:lastname])
        elsif params[:first_name].present?
          Spree::Address::Name.new(params[:first_name], params[:last_name])
        else
          Spree::Address::Name.new
        end
      end

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
