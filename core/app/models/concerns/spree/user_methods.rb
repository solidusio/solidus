module Spree
  module UserMethods
    extend ActiveSupport::Concern

    include UserApiAuthentication
    include UserReporting
    include UserAddress
    include UserPaymentSource

    included do
      has_many :role_users, foreign_key: "user_id", class_name: "Spree::RoleUser"
      has_many :spree_roles, through: :role_users, source: :role

      has_many :user_stock_locations, foreign_key: "user_id", class_name: "Spree::UserStockLocation"
      has_many :stock_locations, through: :user_stock_locations

      has_many :spree_orders, foreign_key: "user_id", class_name: "Spree::Order"
      has_many :orders, foreign_key: "user_id", class_name: "Spree::Order"

      belongs_to :ship_address, class_name: 'Spree::Address'
      belongs_to :bill_address, class_name: 'Spree::Address'

      before_destroy :check_completed_orders
    end

    # has_spree_role? simply needs to return true or false whether a user has a role or not.
    def has_spree_role?(role_in_question)
      spree_roles.any? { |role| role.name == role_in_question.to_s }
    end

    def last_incomplete_spree_order
      spree_orders.incomplete.order('created_at DESC').first
    end

    private

    def check_completed_orders
      raise Spree::Core::DestroyWithOrdersError if orders.complete.present?
    end

  end
end
