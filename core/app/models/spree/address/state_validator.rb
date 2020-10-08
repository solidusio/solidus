# frozen_string_literal: true

module Spree
  class Address::StateValidator
    attr_reader :address
    delegate :state, :state_name, :country, to: :address

    def initialize(address)
      @address = address
    end

    def perform
      return unless state_required?

      if country.present?
        normalize_state if state.present?
        normalize_state_name if state_name.present?
      end

      validate_not_blank
      validate_matches_country
    end

    private

    def normalize_state
      # discard the 'state' attribute when having a country with no states
      address.state = nil if country.states.blank?
    end

    def normalize_state_name
      # discard the 'state_name' when having a valid 'state' and country combo
      if state.present? && state.country == country
        address.state_name = nil
        return
      end

      # set the state from the state name if the country contains one with that name
      states_from_name = country.states.with_name_or_abbr(state_name)
      if states_from_name.size == 1
        address.state = states_from_name.first
        address.state_name = nil
      end
    end

    def validate_not_blank
      if state.blank? && state_name.blank?
        address.errors.add(:state, :blank)
      end
    end

    def validate_matches_country
      if state.present? && state.country != country
        address.errors.add(:state, :does_not_match_country)
      end
    end

    # Don't require a state if disabled at config level or
    # the associated country doesn't require states
    def state_required?
      Spree::Config.address_requires_state && country_requires_states?
    end

    def country_requires_states?
      # default to `true` if country not present
      return true if country.blank?

      country.states_required
    end
  end
end
