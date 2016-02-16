module Spree
  # Default implementation of User.
  #
  # @note This class is intended to be modified by extensions (ex.
  #   spree_auth_devise)
  class LegacyUser < Spree::Base
    include UserMethods

    self.table_name = 'spree_users'

    before_destroy :check_completed_orders

    def self.model_name
      ActiveModel::Name.new Spree::LegacyUser, Spree, 'user'
    end

    attr_accessor :password
    attr_accessor :password_confirmation

    private

    def check_completed_orders
      raise Spree::Core::DestroyWithOrdersError if orders.complete.present?
    end
  end
end
