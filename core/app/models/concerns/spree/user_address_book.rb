module Spree
  module UserAddressBook
    extend ActiveSupport::Concern

    included do
      has_many :user_addresses, foreign_key: "user_id", class_name: "Spree::UserAddress" do
        def find_by_address_values(address_attributes)
          # finds by value, not id
          # since Address is immutable, we treat it like a value object rather than an entity.
          # If your database does not do case sensitive matching on varchar types, then you'll
          # have trouble trying to correct an address field's case
          self.joins(:address).readonly(false).where(
            spree_addresses: address_attributes.stringify_keys.except(*Address::EQUALITY_IRRELEVANT_ATTRS)
          ).first
        end
      end

      has_many :addresses, through: :user_addresses

      has_one :default_user_address, -> { where default: true}, foreign_key: "user_id", class_name: 'Spree::UserAddress'
      has_one :default_address, through: :default_user_address, source: :address

      # bill_address is only minimally used now, but we can't get rid of it without a major version release
      belongs_to :bill_address, class_name: 'Spree::Address'

      def ship_address
        default_address
      end

      def ship_address=(address)
        # TODO default = true for now to preserve existing behavior until MyAccount UI created
        save_in_address_book(address.attributes, true) if address
      end

      def ship_address_attributes=(attributes)
        # see "Nested Attributes Examples" section of http://apidock.com/rails/ActionView/Helpers/FormHelper/fields_for
        # this #{fieldname}_attributes= method works with fields_for in the views
        # even without declaring accepts_nested_attributes_for
        self.ship_address = Address.immutable_merge(ship_address, attributes)
      end

      def bill_address=(address)
        # stow a copy in our address book too
        address = save_in_address_book(address.attributes) if address
        super(address)
      end

      def bill_address_attributes=(attributes)
        self.bill_address = Address.immutable_merge(bill_address, attributes)
      end

      def persist_order_address(order)
        #TODO the 'true' there needs to change once we have MyAccount UI
        save_in_address_book(order.ship_address.attributes, true) if order.ship_address
        save_in_address_book(order.bill_address.attributes, order.ship_address.nil?) if order.bill_address
      end

      def save_in_address_book(address_attributes, default = false)
        return nil unless address_attributes.present?
        user_address = user_addresses.find_by_address_values(address_attributes)
        return user_address.address if user_address && (!default || user_address.default)

        first_one = user_addresses.empty?
        user_address ||= user_addresses.build(address: Address.immutable_merge(nil, address_attributes))
        mark_default_user_address(user_address) if default || first_one

        user_address.save! unless new_record?
        user_address.address
      end

      def mark_default_address(address)
        mark_default_user_address(user_addresses.find_by(address: address))
      end

      private

      def mark_default_user_address(user_address)
        (user_addresses - [user_address]).each {|a| a.update!(default: false)} #update_all would be nice, but it bypasses ActiveRecord callbacks
        user_address.default = true
      end
    end
  end
end
