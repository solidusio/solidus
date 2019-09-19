# frozen_string_literal: true

module Spree
  module UserAddressBook
    extend ActiveSupport::Concern

    included do
      has_many :user_addresses, -> { active }, { foreign_key: "user_id", class_name: "Spree::UserAddress" } do
        def find_first_by_address_values(address_attrs)
          detect { |ua| ua.address == Spree::Address.new(address_attrs) }
        end

        # @note this method enforces only one default address per user
        def mark_default(user_address)
          # the checks of persisted? allow us to build a User and associate Addresses at once
          ActiveRecord::Base.transaction do
            (self - [user_address]).each do |ua| # update_all would be nice, but it bypasses ActiveRecord callbacks
              ua.persisted? ? ua.update!(default: false) : ua.default = false
            end
            user_address.persisted? ? user_address.update!(default: true, archived: false) : user_address.default = true
          end
        end
      end

      has_many :addresses, through: :user_addresses

      # bill_address is only minimally used now, but we can't get rid of it without a major version release
      belongs_to :bill_address, class_name: 'Spree::Address', optional: true

      has_one :default_user_address, ->{ default }, class_name: 'Spree::UserAddress', foreign_key: 'user_id'
      has_one :default_address, through: :default_user_address, source: :address
      alias_method :ship_address, :default_address
    end

    def bill_address=(address)
      # stow a copy in our address book too
      address = save_in_address_book(address.attributes) if address
      super(address)
    end

    def bill_address_attributes=(attributes)
      self.bill_address = Spree::Address.immutable_merge(bill_address, attributes)
    end

    def default_address=(address)
      save_in_address_book(address.attributes, true) if address
    end

    def default_address_attributes=(attributes)
      # see "Nested Attributes Examples" section of http://apidock.com/rails/ActionView/Helpers/FormHelper/fields_for
      # this #{fieldname}_attributes= method works with fields_for in the views
      # even without declaring accepts_nested_attributes_for
      self.default_address = Spree::Address.immutable_merge(default_address, attributes)
    end

    alias_method :ship_address_attributes=, :default_address_attributes=

    # saves address in address book
    # sets address to the default if automatic_default_address is set to true
    # if address is nil, does nothing and returns nil
    def ship_address=(address)
      be_default = Spree::Config.automatic_default_address
      save_in_address_book(address.attributes, be_default) if address
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
        self.ship_address_id = address.id if address && address.persisted?
      end

      if order.bill_address
        address = save_in_address_book(
          order.bill_address.attributes,
          order.ship_address.nil? && Spree::Config.automatic_default_address
        )
        self.bill_address_id = address.id if address && address.persisted?
      end

      save! # In case the ship_address_id or bill_address_id was set
    end

    # Add an address to the user's list of saved addresses for future autofill
    # @param address_attributes HashWithIndifferentAccess of attributes that will be
    # treated as value equality to de-dup among existing Addresses
    # @param default set whether or not this address will show up from
    # #default_address or not
    def save_in_address_book(address_attributes, default = false)
      return nil unless address_attributes.present?
      address_attributes = address_attributes.to_h.with_indifferent_access

      new_address = Spree::Address.factory(address_attributes)
      return new_address unless new_address.valid?

      first_one = user_addresses.empty?

      if address_attributes[:id].present? && new_address.id != address_attributes[:id]
        remove_from_address_book(address_attributes[:id])
      end

      user_address = prepare_user_address(new_address)
      user_addresses.mark_default(user_address) if default || first_one

      if persisted?
        user_address.save!

        # If these associations have already been accessed, they will be
        # caching the existing values.
        # user_addresses need to be reset to get the new ordering based on any changes
        # {default_,}user_address needs to be reset as its result is likely to have changed.
        user_addresses.reset
        association(:default_user_address).reset
        association(:default_address).reset
      end

      user_address.address
    end

    def mark_default_address(address)
      user_addresses.mark_default(user_addresses.find_by(address: address))
    end

    def remove_from_address_book(address_id)
      user_address = user_addresses.find_by(address_id: address_id)
      if user_address
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
  end
end
