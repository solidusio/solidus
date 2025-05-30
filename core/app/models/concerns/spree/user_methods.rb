# frozen_string_literal: true

module Spree
  module UserMethods
    extend ActiveSupport::Concern

    include Spree::UserApiAuthentication
    include Spree::UserReporting
    include Spree::UserAddressBook

    included do
      extend Spree::DisplayMoney

      has_many :role_users,
        foreign_key: "user_id",
        class_name: "Spree::RoleUser",
        dependent: :destroy,
        inverse_of: :user
      has_many :spree_roles,
        through: :role_users,
        source: :role,
        class_name: "Spree::Role",
        inverse_of: :users

      has_many :user_stock_locations,
        foreign_key: "user_id",
        class_name: "Spree::UserStockLocation",
        inverse_of: :user,
        dependent: :destroy
      has_many :stock_locations,
        through: :user_stock_locations,
        inverse_of: :users

      has_many :spree_orders,
        foreign_key: "user_id",
        class_name: "Spree::Order",
        inverse_of: :user,
        dependent: :nullify
      has_many :orders,
        foreign_key: "user_id",
        class_name: "Spree::Order",
        inverse_of: :user,
        dependent: :nullify

      has_many :store_credits,
        -> { includes(:credit_type) },
        foreign_key: "user_id",
        class_name: "Spree::StoreCredit",
        dependent: :nullify,
        inverse_of: :user
      has_many :store_credit_events,
        through: :store_credits,
        inverse_of: false

      has_many :credit_cards,
        class_name: "Spree::CreditCard",
        foreign_key: :user_id,
        dependent: :nullify,
        inverse_of: :user

      has_many :wallet_payment_sources,
        foreign_key: 'user_id',
        class_name: 'Spree::WalletPaymentSource',
        inverse_of: :user,
        dependent: :destroy

      after_create :auto_generate_spree_api_key
      before_destroy :check_for_deletion

      include Spree::RansackableAttributes unless included_modules.include?(Spree::RansackableAttributes)

      ransack_alias :name, :addresses_name
      self.allowed_ransackable_associations = %w[addresses spree_roles]
      self.allowed_ransackable_attributes = %w[name id email created_at]
    end

    def wallet
      @wallet ||= Spree::Wallet.new(self)
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
      self_orders = self_orders.where(store:) if store
      self_orders = self_orders.where('updated_at > ?', Spree::Config.completable_order_updated_cutoff_days.days.ago) if Spree::Config.completable_order_updated_cutoff_days
      self_orders = self_orders.where('created_at > ?', Spree::Config.completable_order_created_cutoff_days.days.ago) if Spree::Config.completable_order_created_cutoff_days
      last_order = self_orders.order(:created_at).last
      last_order unless last_order.try!(:completed?)
    end

    def available_store_credit_total(currency:)
      store_credits.to_a.
        select { |credit| credit.currency == currency }.
        sum(&:amount_remaining)
    end

    def display_available_store_credit_total(currency:)
      Spree::Money.new(
        available_store_credit_total(currency:),
        currency:,
      )
    end

    # Restrict to delete users with existing orders
    #
    # Override this in your user model class to add another logic.
    #
    # Ie. to allow to delete users with incomplete orders add:
    #
    #   orders.complete.none?
    #
    def can_be_deleted?
      orders.none?
    end

    # Updates the roles in keeping with the given ability's permissions
    #
    # Roles that are not accessible to the given ability will be ignored. It
    # also ensure not to remove non accessible roles when assigning new
    # accessible ones.
    #
    # @param given_roles [Spree::Role]
    # @param ability [Spree::Ability]
    def update_spree_roles(given_roles, ability:)
      accessible_roles = Spree::Role.accessible_by(ability)
      non_accessible_roles = Spree::Role.all - accessible_roles
      new_accessible_roles = given_roles - non_accessible_roles
      self.spree_roles = spree_roles - accessible_roles + new_accessible_roles
    end

    private

    def check_for_deletion
      raise ActiveRecord::DeleteRestrictionError unless can_be_deleted?
    end
  end
end
