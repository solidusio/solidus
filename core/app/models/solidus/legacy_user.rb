module Solidus
  # Default implementation of User.
  #
  # @note This class is intended to be modified by extensions (ex.
  #   solidus_auth_devise)
  class LegacyUser < Solidus::Base
    include UserMethods

    self.table_name = 'solidus_users'

    # for url generation
    def self.model_name
      ActiveModel::Name.new(self, nil, "User")
    end

    before_destroy :check_completed_orders

    def self.model_name
      ActiveModel::Name.new Solidus::LegacyUser, Solidus, 'user'
    end

    attr_accessor :password
    attr_accessor :password_confirmation

    private
    def check_completed_orders
      raise Solidus::Core::DestroyWithOrdersError if orders.complete.present?
    end
  end
end
