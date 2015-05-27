module Spree
  # Default implementation of User.
  #
  # @note This class is intended to be modified by extensions (ex.
  #   spree_auth_devise)
  class LegacyUser < Spree::Base
    include UserMethods
    attr_accessor :password, :password_confirmation
    self.table_name = 'spree_users'
  end
end
