# frozen_string_literal: true

module Spree
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country_id` and `:principal_subdivision_id`.
    #
    # @attr_reader [Integer] country_id the ID of a Spree::Country object
    # @attr_reader [Integer] principal_subdivision_id the ID of a Spree::State object
    class TaxLocation
      attr_reader :country, :principal_subdivision

      # Create a new TaxLocation object
      #
      # @see Spree::Zone.for_address
      #
      # @param [Spree::Country] country a Spree::Country object, default: nil
      # @param [Spree::State] principal_subdivision a Spree::State object, default: nil
      #
      # @return [Spree::Tax::TaxLocation] a Spree::Tax::TaxLocation object
      def initialize(country: nil, principal_subdivision: nil, state: nil)
        if state
          Spree.deprecator.warn(
            "Passing `state:` to Spree::Tax::TaxLocation is deprecated, use `principal_subdivision:` instead."
          )
        end

        @country = country
        @principal_subdivision = principal_subdivision || state
      end
      delegate :id, to: :principal_subdivision, prefix: true, allow_nil: true
      delegate :id, to: :country, prefix: true, allow_nil: true

      alias_method :state, :principal_subdivision
      alias_method :state_id, :principal_subdivision_id
      deprecate(
        state: :principal_subdivision,
        state_id: :principal_subdivision_id,
        deprecator: Spree.deprecator
      )

      def ==(other)
        principal_subdivision_id == other.principal_subdivision_id && country_id == other.country_id
      end

      def empty?
        country_id.nil? && principal_subdivision_id.nil?
      end
    end
  end
end
