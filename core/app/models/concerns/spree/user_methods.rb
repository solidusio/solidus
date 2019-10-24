# frozen_string_literal: true

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
      has_many :spree_roles, through: :role_users, source: :role, class_name: "Spree::Role"

      has_many :user_stock_locations, foreign_key: "user_id", class_name: "Spree::UserStockLocation"
      has_many :stock_locations, through: :user_stock_locations

      has_many :spree_orders, foreign_key: "user_id", class_name: "Spree::Order"
      has_many :orders, foreign_key: "user_id", class_name: "Spree::Order", dependent: :restrict_with_exception

      has_many :store_credits, -> { includes(:credit_type) }, foreign_key: "user_id", class_name: "Spree::StoreCredit"
      has_many :store_credit_events, through: :store_credits

      money_methods :total_available_store_credit
      deprecate display_total_available_store_credit: :display_available_store_credit_total, deprecator: Spree::Deprecation

      has_many :credit_cards, class_name: "Spree::CreditCard", foreign_key: :user_id
      has_many :wallet_payment_sources, foreign_key: 'user_id', class_name: 'Spree::WalletPaymentSource', inverse_of: :user

      after_create :auto_generate_spree_api_key

      include Spree::RansackableAttributes unless included_modules.include?(Spree::RansackableAttributes)

      self.whitelisted_ransackable_associations = %w[addresses spree_roles]
      self.whitelisted_ransackable_attributes = %w[id email created_at]
    end

    def wallet
      Spree::Wallet.new(self)
    end

    # has_spree_role? simply needs to return true or false whether a user has a role or not.
    def has_spree_role?(role_in_question)
      spree_roles.any? { |role| role.name == role_in_question.to_s }
    end

    def auto_generate_spree_api_key
      return if !respond_to?(:spree_api_key) || spree_api_key.present?

      if Spree::Config.generate_api_key_for_all_roles || (spree_roles.map(&:name) & Spree::Config.roles_for_auto_api_key).any?
        generate_spree_api_key!
      end
    end

    # @return [Spree::Order] the most-recently-created incomplete order
    # since the customer's last complete order.
    def last_incomplete_spree_order(store: nil, only_frontend_viewable: true)
      self_orders = orders
      self_orders = self_orders.where(frontend_viewable: true) if only_frontend_viewable
      self_orders = self_orders.where(store: store) if store
      self_orders = self_orders.where('updated_at > ?', Spree::Config.completable_order_updated_cutoff_days.days.ago) if Spree::Config.completable_order_updated_cutoff_days
      self_orders = self_orders.where('created_at > ?', Spree::Config.completable_order_created_cutoff_days.days.ago) if Spree::Config.completable_order_created_cutoff_days
      last_order = self_orders.order(:created_at).last
      last_order unless last_order.try!(:completed?)
    end

    def total_available_store_credit
      store_credits.reload.to_a.sum(&:amount_remaining)
    end
    deprecate total_available_store_credit: :available_store_credit_total, deprecator: Spree::Deprecation

    def available_store_credit_total(currency:)
      store_credits.to_a.
        select { |credit| credit.currency == currency }.
        sum(&:amount_remaining)
    end

    def display_available_store_credit_total(currency:)
      Spree::Money.new(
        available_store_credit_total(currency: currency),
        currency: currency,
      )
    end
  end
end
