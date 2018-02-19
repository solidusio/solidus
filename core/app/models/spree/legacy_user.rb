# frozen_string_literal: true

module Spree
  # Default implementation of User.
  #
  # @note This class is intended to be modified by extensions (ex.
  #   spree_auth_devise)
  class LegacyUser < Spree::Base
    include UserMethods

    self.table_name = 'spree_users'

    def self.model_name
      ActiveModel::Name.new Spree::LegacyUser, Spree, 'user'
    end

    attr_accessor :password
    attr_accessor :password_confirmation
  end
end
