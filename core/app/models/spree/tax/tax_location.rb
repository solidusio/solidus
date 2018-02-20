# frozen_string_literal: true

module Spree
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country_id` and `:state_id`.
    #
    # @attr_reader [Integer] country_id the ID of a Spree::Country object
    # @attr_reader [Integer] state_id the ID of a Spree::State object
    class TaxLocation
      attr_reader :country_id, :state_id

      # Create a new TaxLocation object
      #
      # @see Spree::Zone.for_address
      #
      # @param [Spree::Country] country a Spree::Country object, default: nil
      # @param [Spree::State] state a Spree::State object, default: nil
      #
      # @return [Spree::Tax::TaxLocation] a Spree::Tax::TaxLocation object
      def initialize(country: nil, state: nil)
        @country_id = country && country.id
        @state_id = state && state.id
      end

      def ==(other)
        state_id == other.state_id && country_id == other.country_id
      end

      def country
        Spree::Country.find_by(id: country_id)
      end

      def empty?
        country_id.nil? && state_id.nil?
      end
    end
  end
end
