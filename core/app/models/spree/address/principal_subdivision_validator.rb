# frozen_string_literal: true

module Spree
  class Address::PrincipalSubdivisionValidator
    attr_reader :address
    delegate :principal_subdivision, :principal_subdivision_name, :country, to: :address

    def initialize(address)
      @address = address
    end

    def perform
      return unless principal_subdivision_required?

      if country.present?
        normalize_principal_subdivision if principal_subdivision.present?
        normalize_principal_subdivision_name if principal_subdivision_name.present?
      end

      validate_not_blank
      validate_matches_country
    end

    private

    def normalize_principal_subdivision
      # discard the 'principal_subdivision' attribute when having a country with no states
      address.principal_subdivision = nil if country.states.blank?
    end

    def normalize_principal_subdivision_name
      # discard the 'principal_subdivision_name' when having a valid
      # 'principal_subdivision' and country combo
      if principal_subdivision.present? && principal_subdivision.country == country
        address.principal_subdivision_name = nil
        return
      end

      # set the principal subdivision from its name if the country contains one with that name
      states_from_name = country.states.with_name_or_abbr(principal_subdivision_name)
      if states_from_name.size == 1
        address.principal_subdivision = states_from_name.first
        address.principal_subdivision_name = nil
      end
    end

    def validate_not_blank
      if principal_subdivision.blank? && principal_subdivision_name.blank?
        address.errors.add(:principal_subdivision, :blank)
      end
    end

    def validate_matches_country
      if principal_subdivision.present? && principal_subdivision.country != country
        address.errors.add(:principal_subdivision, :does_not_match_country)
      end
    end

    # Don't require a principal subdivision if disabled at config level or
    # the associated country doesn't require states
    def principal_subdivision_required?
      Spree::Config.address_requires_state && country_requires_states?
    end

    def country_requires_states?
      # default to `true` if country not present
      return true if country.blank?

      country.states_required
    end
  end
end
