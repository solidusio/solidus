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

    validates :address1, :city, :country_id, presence: true
    validates :zipcode, presence: true, if: :require_zipcode?
    validates :phone, presence: true, if: :require_phone?

    validate :validate_name
    validate :state_validate
    validate :validate_state_matches_country

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname
    alias_attribute :full_name, :name

    DB_ONLY_ATTRS = %w(id updated_at created_at)
    TAXATION_ATTRS = %w(state_id country_id zipcode)
    LEGACY_NAME_ATTRS = %w(firstname lastname full_name)

    self.whitelisted_ransackable_attributes = %w[firstname lastname]

    scope :with_values, ->(attributes) do
      where(value_attributes(attributes))
    end

    Spree::Deprecation.deprecate_methods(
      Spree::Address,
      LEGACY_NAME_ATTRS.product([:name]).to_h
    )

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

      name_from_attributes = Spree::Address::Name.from_attributes(base)
      if base['firstname'].presence || base['first_name'].presence
        base['firstname'] = name_from_attributes.first_name
      end
      if base['lastname'].presence || base['last_name'].presence
        base['lastname'] = name_from_attributes.last_name
      end
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

    # @return [String] a string representation of this state
    def state_text
      state.try(:abbr) || state.try(:name) || state_name
    end

    def to_s
      "#{name}: #{address1}"
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
        name: name,
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

    # @return [String] the full name on this address
    def name
      Spree::Address::Name.new(
        read_attribute(:firstname),
        read_attribute(:lastname)
      ).value
    end

    def name=(value)
      return if value.nil?

      name_from_value = Spree::Address::Name.new(value)
      write_attribute(:firstname, name_from_value.first_name)
      write_attribute(:lastname, name_from_value.last_name)
    end

    def as_json(options = {})
      if Spree::Config.use_combined_first_and_last_name_in_address
        super(options.merge(except: LEGACY_NAME_ATTRS)).tap do |hash|
          hash['name'] = name
        end
      else
        super
      end
    end

    private

    def validate_name
      return if name.present?

      name_attribute = if Spree::Config.use_combined_first_and_last_name_in_address
        :name
      else
        :firstname
      end
      errors.add(name_attribute, :blank)
    end

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
