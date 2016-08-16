require 'twitter_cldr'

module Spree
  class Address < Spree::Base
    extend ActiveModel::ForbiddenAttributesProtection

    belongs_to :country, class_name: "Spree::Country"
    belongs_to :state, class_name: "Spree::State"

    validates :firstname, :lastname, :address1, :city, :country_id, presence: true
    validates :zipcode, presence: true, if: :require_zipcode?
    validates :phone, presence: true, if: :require_phone?

    validate :state_validate, :postal_code_validate

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname

    DB_ONLY_ATTRS = %w(id updated_at created_at)
    TAXATION_ATTRS = %w(state_id country_id zipcode)

    self.whitelisted_ransackable_attributes = %w[firstname lastname]

    scope :with_values, ->(attributes) do
      where(value_attributes(attributes))
    end

    def self.build_default
      new(country: Spree::Country.default)
    end

    def self.default(user = nil, kind = "bill")
      Spree::Deprecation.warn("Address.default is deprecated. Use User.default_address or Address.build_default", caller)
      if user
        user.send(:"#{kind}_address") || build_default
      else
        build_default
      end
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
    def self.value_attributes(base_attributes, merge_attributes = nil)
      # dup because we may modify firstname/lastname.
      base = base_attributes.dup

      base.stringify_keys!

      if merge_attributes
        base.merge!(merge_attributes.stringify_keys)
      end

      # TODO: Deprecate these aliased attributes
      base['firstname'] = base.delete('first_name') if base.key?('first_name')
      base['lastname'] = base.delete('last_name') if base.key?('last_name')

      base.except!(*DB_ONLY_ATTRS)
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

    def same_as?(other_address)
      Spree::Deprecation.warn("Address.same_as? is deprecated. It's equivalent to Address.==", caller)
      self == other_address
    end

    def same_as(other_address)
      Spree::Deprecation.warn("Address.same_as is deprecated. It's equivalent to Address.==", caller)
      self == other_address
    end

    def empty?
      attributes.except('id', 'created_at', 'updated_at', 'country_id').all? { |_, v| v.nil? }
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
      self.country = Country.find_by!(iso: iso)
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
          states = country.states.find_all_by_name_or_abbr(state_name)

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

    def postal_code_validate
      return if country.blank? || country.iso.blank? || !require_zipcode?
      return if !TwitterCldr::Shared::PostalCodes.territories.include?(country.iso.downcase.to_sym)

      postal_code = TwitterCldr::Shared::PostalCodes.for_territory(country.iso)
      errors.add(:zipcode, :invalid) if !postal_code.valid?(zipcode.to_s)
    end
  end
end
