module Spree
  module UserMethods
    extend ActiveSupport::Concern

    include Spree::UserApiAuthentication
    include Spree::UserReporting
    include Spree::UserAddressBook
    include Spree::UserPaymentSource

    included do
      extend Spree::DisplayMoney

      has_many :role_users, foreign_key: "user_id", class_name: "Spree::RoleUser", dependent: :destroy
      has_many :spree_roles, through: :role_users, source: :role

      has_many :user_stock_locations, foreign_key: "user_id", class_name: "Spree::UserStockLocation"
      has_many :stock_locations, through: :user_stock_locations

      has_many :spree_orders, foreign_key: "user_id", class_name: "Spree::Order"
      has_many :orders, foreign_key: "user_id", class_name: "Spree::Order"

      has_many :store_credits, -> { includes(:credit_type) }, foreign_key: "user_id", class_name: "Spree::StoreCredit"
      has_many :store_credit_events, through: :store_credits
      money_methods :total_available_store_credit

      def self.ransackable_associations(auth_object=nil)
        %w[addresses]
      end

      def self.ransackable_attributes(auth_object=nil)
        %w[id email]
      end
    end

    # has_spree_role? simply needs to return true or false whether a user has a role or not.
    def has_spree_role?(role_in_question)
      spree_roles.any? { |role| role.name == role_in_question.to_s }
    end

    # @return [Spree::Order] the most-recently-created incomplete order
    # since the customer's last complete order.
    def last_incomplete_spree_order(store: nil, only_frontend_viewable: true)
      self_orders = self.orders
      self_orders = self_orders.where(frontend_viewable: true) if only_frontend_viewable
      self_orders = self_orders.where(store: store) if store
      last_order = self_orders.order(:created_at).last
      last_order unless last_order.try!(:completed?)
    end

    def total_available_store_credit
      store_credits.reload.to_a.sum{ |credit| credit.amount_remaining }
    end
  end
end
