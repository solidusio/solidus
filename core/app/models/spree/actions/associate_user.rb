module Spree
  module Actions
    class AssociateUser
      attr_reader :order, :user, :override_email

      def initialize(order, user, override_email: true)
        @order = order
        @user = user
        @override_email = override_email
      end

      def perform
        order.user = user
        attrs_to_set = { user_id: user.try!(:id) }
        attrs_to_set[:email] = user.try!(:email) if override_email
        attrs_to_set[:created_by_id] = user.try!(:id) if order.created_by.blank?

        if order.persisted?
          # immediately persist the changes we just made, but don't use save since we might have an invalid address associated
          Spree::Order.unscoped.where(id: order.id).update_all(attrs_to_set)
        end

        attrs_to_set[:ship_address_attributes] = user.ship_address.attributes.except('id', 'updated_at', 'created_at') if user.try!(:ship_address)
        attrs_to_set[:bill_address_attributes] = user.bill_address.attributes.except('id', 'updated_at', 'created_at') if user.try!(:bill_address)
        order.assign_attributes(attrs_to_set)
      end
    end
  end
end
