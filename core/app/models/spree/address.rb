# frozen_string_literal: true

module Spree
  # `Spree::Address` provides the foundational ActiveRecord model for recording and
  # validating address information for `Spree::Order`, `Spree::Shipment`,
  # `Spree::UserAddress`, and `Spree::Carton`.
  #
  class Address < Spree::Base
    extend ActiveModel::ForbiddenAttributesProtection

    belongs_to :country, class_name: "Spree::Country", optional: true
    belongs_to :state, class_name: "Spree::State", optional: true

    validates :firstname, :address1, :city, :country_id, presence: true
    validates :zipcode, presence: true, if: :require_zipcode?
    validates :phone, presence: true, if: :require_phone?

    validate :state_validate
    validate :validate_state_matches_country

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname

    DB_ONLY_ATTRS = %w(id updated_at created_at)
    TAXATION_ATTRS = %w(state_id country_id zipcode)

    self.whitelisted_ransackable_attributes = %w[firstname lastname]

    scope :with_values, ->(attributes) do
      where(value_attributes(attributes))
    end

    # @return [Address] an address with default attributes
    def self.build_default(*args, &block)
      where(country: Spree::Country.default).build(*args, &block)
    end

    # @return [Address] an equal address already in the database or a newly created one
    def self.factory(attributes)
      full_attributes = value_attributes(column_defaults, new(attributes).attributes)
      find_or_initialize_by(full_attributes)
    end

    # @return [Address] address from existing address plus new_attributes as diff
    # @note, this may return existing_address if there are no changes to value equality
    def self.immutable_merge(existing_address, new_attributes)
      # Ensure new_attributes is a sanitized hash
      new_attributes = sanitize_for_mass_assignment(new_attributes)

      return factory(new_attributes) if existing_address.nil?

      merged_attributes = value_attributes(existing_address.attributes, new_attributes)
      new_address = factory(merged_attributes)
      if existing_address == new_address
        existing_address
      else
        new_address
      end
    end

    # @return [Hash] hash of attributes contributing to value equality with optional merge
    def self.value_attributes(base_attributes, merge_attributes = {})
      base = base_attributes.stringify_keys.merge(merge_attributes.stringify_keys)

      # TODO: Deprecate these aliased attributes
      base['firstname'] = base['first_name'] if base.key?('first_name')
      base['lastname'] = base['last_name'] if base.key?('last_name')

      excluded_attributes = DB_ONLY_ATTRS + %w(first_name last_name)

      base.except(*excluded_attributes)
    end

    # @return [Hash] hash of attributes contributing to value equality
    def value_attributes
      self.class.value_attributes(attributes)
    end

    def taxation_attributes
      self.class.value_attributes(attributes.slice(*TAXATION_ATTRS))
    end

    # @return [String] the full name on this address
    def full_name
      "#{firstname} #{lastname}".strip
    end

    # @return [String] a string representation of this state
    def state_text
      state.try(:abbr) || state.try(:name) || state_name
    end

    def to_s
      "#{full_name}: #{address1}"
    end

    # @note This compares the addresses based on only the fields that make up
    #   the logical "address" and excludes the database specific fields (id, created_at, updated_at).
    # @return [Boolean] true if the two addresses have the same address fields
    def ==(other_address)
      return false unless other_address && other_address.respond_to?(:value_attributes)
      value_attributes == other_address.value_attributes
    end

    # @deprecated Do not use this. Use Address.== instead.
    def same_as?(other_address)
      Spree::Deprecation.warn("Address#same_as? is deprecated. It's equivalent to Address.==", caller)
      self == other_address
    end

    # @deprecated Do not use this. Use Address.== instead.
    def same_as(other_address)
      Spree::Deprecation.warn("Address#same_as is deprecated. It's equivalent to Address.==", caller)
      self == other_address
    end

    # @deprecated Do not use this
    def empty?
      Spree::Deprecation.warn("Address#empty? is deprecated.", caller)
      attributes.except('id', 'created_at', 'updated_at', 'country_id').all? { |_, value| value.nil? }
    end

    # This exists because the default Object#blank?, checks empty? if it is
    # defined, and we have defined empty.
    # This should be removed once empty? is removed
    def blank?
      false
    end

    # @return [Hash] an ActiveMerchant compatible address hash
    def active_merchant_hash
      {
        name: full_name,
        address1: address1,
        address2: address2,
        city: city,
        state: state_text,
        zip: zipcode,
        country: country.try(:iso),
        phone: phone
      }
    end

    # @todo Remove this from the public API if possible.
    # @return [true] whether or not the address requires a phone number to be
    #   valid
    def require_phone?
      true
    end

    # @todo Remove this from the public API if possible.
    # @return [true] whether or not the address requires a zipcode to be valid
    def require_zipcode?
      true
    end

    # This is set in order to preserve immutability of Addresses. Use #dup to create
    # new records as required, but it probably won't be required as often as you think.
    # Since addresses do not change, you won't accidentally alter historical data.
    def readonly?
      persisted?
    end

    # @param iso [String] 2 letter Country ISO
    # @return [Country] setter that sets self.country to the Country with a matching 2 letter iso
    # @raise [ActiveRecord::RecordNotFound] if country with the iso doesn't exist
    def country_iso=(iso)
      self.country = Spree::Country.find_by!(iso: iso)
    end

    def country_iso
      country && country.iso
    end

    private

    def state_validate
      # Skip state validation without country (also required)
      # or when disabled by preference
      return if country.blank? || !Spree::Config[:address_requires_state]
      return unless country.states_required

      # ensure associated state belongs to country
      if state.present?
        if state.country == country
          self.state_name = nil # not required as we have a valid state and country combo
        elsif state_name.present?
          self.state = nil
        else
          errors.add(:state, :invalid)
        end
      end

      # ensure state_name belongs to country without states, or that it matches a predefined state name/abbr
      if state_name.present?
        if country.states.present?
          states = country.states.with_name_or_abbr(state_name)

          if states.size == 1
            self.state = states.first
            self.state_name = nil
          else
            errors.add(:state, :invalid)
          end
        end
      end

      # ensure at least one state field is populated
      errors.add :state, :blank if state.blank? && state_name.blank?
    end

    def validate_state_matches_country
      if state && state.country != country
        errors.add(:state, :does_not_match_country)
      end
    end
  end
end
