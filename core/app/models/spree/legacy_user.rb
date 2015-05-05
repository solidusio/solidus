module Spree
  # Default implementation of User.
  #
  # @note This class is intended to be modified by extensions (ex.
  #   spree_auth_devise)
  class LegacyUser < Spree::Base
    include UserAddress
    include UserPaymentSource

    self.table_name = 'spree_users'

    # for url generation
    def self.model_name
      ActiveModel::Name.new(self, nil, "User")
    end

    has_many :orders, foreign_key: :user_id

    before_destroy :check_completed_orders

    def has_spree_role?(role)
      true
    end

    attr_accessor :password
    attr_accessor :password_confirmation

    private

      def check_completed_orders
        raise Spree::Core::DestroyWithOrdersError if orders.complete.present?
      end
  end
end
