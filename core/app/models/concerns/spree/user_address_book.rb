# frozen_string_literal: true

module Spree
  module UserAddressBook
    extend ActiveSupport::Concern

    included do
      has_many :user_addresses, -> { active }, { foreign_key: "user_id", class_name: "Spree::UserAddress" } do
        def find_first_by_address_values(address_attrs)
          detect { |ua| ua.address == Spree::Address.new(address_attrs) }
        end

        def mark_default(user_address, address_type: :shipping)
          column_for_default = address_type == :shipping ? :default : :default_billing
          ActiveRecord::Base.transaction do
            (self - [user_address]).each do |address| # update_all would be nice, but it bypasses ActiveRecord callbacks
              if address.persisted?
                address.update!(column_for_default => false)
              else
                address.write_attribute(column_for_default, false)
              end
            end

            if user_address.persisted?
              user_address.update!(column_for_default => true, archived: false)
            else
              user_address.write_attribute(column_for_default, true)
            end
          end
        end
      end

      has_many :addresses, through: :user_addresses

      has_one :default_user_bill_address, ->{ default_billing }, class_name: 'Spree::UserAddress', foreign_key: 'user_id'
      has_one :bill_address, through: :default_user_bill_address, source: :address

      has_one :default_user_ship_address, ->{ default_shipping }, class_name: 'Spree::UserAddress', foreign_key: 'user_id'
      has_one :ship_address, through: :default_user_ship_address, source: :address
    end

    def default_address
      Spree::Deprecation.warn "#default_address is deprecated. Please start using #ship_address."
      ship_address
    end

    def default_user_address
      Spree::Deprecation.warn "#default_user_address is deprecated. Please start using #default_user_ship_address."
      default_user_ship_address
    end

    def default_address=(address)
      Spree::Deprecation.warn(
        "#default_address= does not take Spree::Config.automatic_default_address into account and is deprecated. " \
        "Please use #ship_address=."
      )

      self.ship_address = address if address
    end

    def default_address_attributes=(attributes)
      # see "Nested Attributes Examples" section of http://apidock.com/rails/ActionView/Helpers/FormHelper/fields_for
      # this #{fieldname}_attributes= method works with fields_for in the views
      # even without declaring accepts_nested_attributes_for
      Spree::Deprecation.warn "#default_address_attributes= is deprecated. Please use #ship_address_attributes=."

      self.default_address = Spree::Address.immutable_merge(ship_address, attributes)
    end

    # saves address in address book
    # sets address to the default if automatic_default_address is set to true
    # if address is nil, does nothing and returns nil
    def ship_address=(address)
      if address
        save_in_address_book(address.attributes,
                             Spree::Config.automatic_default_address)
      end
    end

    def ship_address_attributes=(attributes)
      self.ship_address = Spree::Address.immutable_merge(ship_address, attributes)
    end

    def bill_address=(address)
      if address
        save_in_address_book(address.attributes,
                             Spree::Config.automatic_default_address,
                             :billing)
      end
    end

    def bill_address_attributes=(attributes)
      self.bill_address = Spree::Address.immutable_merge(bill_address, attributes)
    end

    # saves order.ship_address and order.bill_address in address book
    # sets ship_address to the default if automatic_default_address is set to true
    # sets bill_address to the default if automatic_default_address is set to true and there is no ship_address
    # if one address is nil, does not save that address
    def persist_order_address(order)
      if order.ship_address
        address = save_in_address_book(
          order.ship_address.attributes,
          Spree::Config.automatic_default_address
        )
        self.ship_address_id = address.id if address&.persisted?
      end

      if order.bill_address
        address = save_in_address_book(
          order.bill_address.attributes,
          Spree::Config.automatic_default_address,
          :billing
        )
        self.bill_address_id = address.id if address&.persisted?
      end

      save! # In case the ship_address_id or bill_address_id was set
    end

    # Add an address to the user's list of saved addresses for future autofill
    # @param address_attributes HashWithIndifferentAccess of attributes that will be
    # treated as value equality to de-dup among existing Addresses
    # @param default set whether or not this address will show up from
    # #default_address or not
    def save_in_address_book(address_attributes, default = false, address_type = :shipping)
      return nil if address_attributes.blank?

      address_attributes = address_attributes.to_h.with_indifferent_access

      new_address = Spree::Address.factory(address_attributes)
      return new_address unless new_address.valid?

      first_one = user_addresses.empty?

      if address_attributes[:id].present? && new_address.id != address_attributes[:id]
        remove_from_address_book(address_attributes[:id])
      end

      user_address = prepare_user_address(new_address)
      user_addresses.mark_default(user_address, address_type: address_type) if default || first_one

      if persisted?
        user_address.save!

        # If these associations have already been accessed, they will be
        # caching the existing values.
        # user_addresses need to be reset to get the new ordering based on any changes
        # {default_,}user_address needs to be reset as its result is likely to have changed.
        user_addresses.reset
        association(:default_user_ship_address).reset
        association(:ship_address).reset
        association(:default_user_bill_address).reset
        association(:bill_address).reset
      end

      user_address.address
    end

    def mark_default_address(address)
      Spree::Deprecation.warn(
        "#mark_default_address is deprecated and it sets the ship_address only. " \
        "Please use #mark_default_ship_address."
      )

      mark_default_ship_address(address)
    end

    def mark_default_ship_address(address)
      user_addresses.mark_default(user_addresses.find_by(address: address))
    end

    def mark_default_bill_address(address)
      user_addresses.mark_default(user_addresses.find_by(address: address), address_type: :billing)
    end

    def remove_from_address_book(address_id)
      user_address = user_addresses.find_by(address_id: address_id)
      if user_address
        remove_user_address_reference(address_id)
        user_address.update(archived: true, default: false)
      else
        false
      end
    end

    private

    def prepare_user_address(new_address)
      user_address = user_addresses.all_historical.find_first_by_address_values(new_address.attributes)
      user_address ||= user_addresses.build
      user_address.address = new_address
      user_address.archived = false
      user_address
    end

    def remove_user_address_reference(address_id)
      self.bill_address_id = bill_address_id == address_id.to_i ? nil : bill_address_id
      self.ship_address_id = ship_address_id == address_id.to_i ? nil : ship_address_id
      save if changed?
    end
  end
end
