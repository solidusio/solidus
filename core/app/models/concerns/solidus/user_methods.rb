module Spree
  module UserMethods
    extend ActiveSupport::Concern

    include Solidus::UserApiAuthentication
    include Solidus::UserReporting
    include Solidus::UserAddressBook
    include Solidus::UserPaymentSource

    included do
      extend Solidus::DisplayMoney

      has_many :role_users, foreign_key: "user_id", class_name: "Solidus::RoleUser", dependent: :destroy
      has_many :spree_roles, through: :role_users, source: :role

      has_many :user_stock_locations, foreign_key: "user_id", class_name: "Solidus::UserStockLocation"
      has_many :stock_locations, through: :user_stock_locations

      has_many :spree_orders, foreign_key: "user_id", class_name: "Solidus::Order"
      has_many :orders, foreign_key: "user_id", class_name: "Solidus::Order"

      has_many :store_credits, -> { includes(:credit_type) }, foreign_key: "user_id", class_name: "Solidus::StoreCredit"
      has_many :store_credit_events, through: :store_credits
      money_methods :total_available_store_credit

      after_create :auto_generate_spree_api_key

      include Solidus::RansackableAttributes unless included_modules.include?(Solidus::RansackableAttributes)

      self.whitelisted_ransackable_associations = %w[addresses]
      self.whitelisted_ransackable_attributes = %w[id email]
    end

    # has_spree_role? simply needs to return true or false whether a user has a role or not.
    def has_spree_role?(role_in_question)
      spree_roles.any? { |role| role.name == role_in_question.to_s }
    end

    def auto_generate_spree_api_key
      return if !respond_to?(:spree_api_key) || spree_api_key.present?

      if Solidus::Config.generate_api_key_for_all_roles || (spree_roles.map(&:name) & Solidus::Config.roles_for_auto_api_key).any?
        generate_spree_api_key!
      end
    end

    # @return [Solidus::Order] the most-recently-created incomplete order
    # since the customer's last complete order.
    def last_incomplete_spree_order(store: nil, only_frontend_viewable: true)
      self_orders = self.orders
      self_orders = self_orders.where(frontend_viewable: true) if only_frontend_viewable
      self_orders = self_orders.where(store: store) if store
      self_orders = self_orders.where('updated_at > ?', Solidus::Config.completable_order_updated_cutoff_days.days.ago) if Solidus::Config.completable_order_updated_cutoff_days
      self_orders = self_orders.where('created_at > ?', Solidus::Config.completable_order_created_cutoff_days.days.ago) if Solidus::Config.completable_order_created_cutoff_days
      last_order = self_orders.order(:created_at).last
      last_order unless last_order.try!(:completed?)
    end

    def total_available_store_credit
      store_credits.reload.to_a.sum{ |credit| credit.amount_remaining }
    end
  end
end
