module Spree
  module UserAddress
    extend ActiveSupport::Concern

    included do
      belongs_to :bill_address, foreign_key: :bill_address_id, class_name: 'Spree::Address'
      alias_attribute :billing_address, :bill_address

      belongs_to :ship_address, foreign_key: :ship_address_id, class_name: 'Spree::Address'
      alias_attribute :shipping_address, :ship_address

      accepts_nested_attributes_for :ship_address, :bill_address

      def persist_order_address(order)
        if self.bill_address != order.bill_address
          b_address = order.bill_address.dup || self.build_bill_address
          b_address.save
          self.update_attributes(bill_address_id: b_address.id)
        end

        # May not be present if delivery step has been removed
        if order.ship_address && self.ship_address != order.ship_address
          s_address = order.ship_address.dup || self.build_ship_address
          s_address.save
          self.update_attributes(ship_address_id: s_address.id)
        end
      end
    end
  end
end
