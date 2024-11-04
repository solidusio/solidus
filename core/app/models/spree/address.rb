# frozen_string_literal: true

module Spree
  # `Spree::Address` provides the foundational ActiveRecord model for recording and
  # validating address information for `Spree::Order`, `Spree::Shipment`,
  # `Spree::UserAddress`, and `Spree::Carton`.
  #
  class Address < Spree::Base
    extend ActiveModel::ForbiddenAttributesProtection

    mattr_accessor :state_validator_class
    self.state_validator_class = Spree::Address::StateValidator

    belongs_to :country, class_name: "Spree::Country", optional: true
    belongs_to :state, class_name: "Spree::State", optional: true

    validates :address1, :city, :country_id, :name, presence: true
    validates :zipcode, presence: true, if: :require_zipcode?
    validates :phone, presence: true, if: :require_phone?

    validate do
      self.class.state_validator_class.new(self).perform
    end

    self.ignored_columns = %w(firstname lastname)
    DB_ONLY_ATTRS = %w(id updated_at created_at).freeze
    TAXATION_ATTRS = %w(state_id country_id zipcode).freeze

    self.allowed_ransackable_attributes = %w[name]

    unless ActiveRecord::Relation.method_defined? :with_values # Rails 7.1+
      scope :with_values, ->(attributes) do
        where(value_attributes(attributes))
      end
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
      base.except(*DB_ONLY_ATTRS)
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

    # @return [Hash] an ActiveMerchant compatible address hash
    def active_merchant_hash
      {
        name:,
        address1:,
        address2:,
        city:,
        state: state_text,
        zip: zipcode,
        country: country.try(:iso),
        phone:
      }
    end

    # @todo Remove this from the public API if possible.
    # @return [true] whether or not the address requires a phone number to be
    #   present
    def require_phone?
      Spree::Config[:address_requires_phone]
    end

    # @todo Remove this from the public API if possible.
    # @return [true] whether or not the address requires a zipcode to be present
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
      self.country = Spree::Country.find_by!(iso:)
    end

    def country_iso
      country && country.iso
    end
  end
end
