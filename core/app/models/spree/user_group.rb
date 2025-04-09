# frozen_string_literal: true

module Spree
  class UserGroup < Spree::Base
    has_many :users, class_name: Spree::UserClassHandle.new
    has_one :store, class_name: 'Spree::Store', foreign_key: 'default_cart_user_group_id'

    validates :group_name, presence: true
  end
end
