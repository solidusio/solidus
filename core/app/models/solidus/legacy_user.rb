# frozen_string_literal: true

module Solidus
  # Default implementation of User.
  #
  # @note This class is intended to be modified by extensions (ex.
  #   spree_auth_devise)
  class LegacyUser < Solidus::Base
    include UserMethods

    self.table_name = 'spree_users'

    def self.model_name
      ActiveModel::Name.new Solidus::LegacyUser, Solidus, 'user'
    end

    attr_accessor :password
    attr_accessor :password_confirmation
  end
end
