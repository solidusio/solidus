# frozen_string_literal: true

module Spree
  class PermissionSet < Spree::Base
    has_many :role_permissions
    has_many :roles, through: :role_permissions

    validates :name, :group, presence: true
  end
end
