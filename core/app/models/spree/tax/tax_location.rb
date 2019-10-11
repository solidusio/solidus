# frozen_string_literal: true

module Solidus
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country_id` and `:state_id`.
    #
    # @attr_reader [Integer] country_id the ID of a Solidus::Country object
    # @attr_reader [Integer] state_id the ID of a Solidus::State object
    class TaxLocation
      attr_reader :country_id, :state_id

      # Create a new TaxLocation object
      #
      # @see Solidus::Zone.for_address
      #
      # @param [Solidus::Country] country a Solidus::Country object, default: nil
      # @param [Solidus::State] state a Solidus::State object, default: nil
      #
      # @return [Solidus::Tax::TaxLocation] a Solidus::Tax::TaxLocation object
      def initialize(country: nil, state: nil)
        @country_id = country && country.id
        @state_id = state && state.id
      end

      def ==(other)
        state_id == other.state_id && country_id == other.country_id
      end

      def country
        Solidus::Country.find_by(id: country_id)
      end

      def empty?
        country_id.nil? && state_id.nil?
      end
    end
  end
end
