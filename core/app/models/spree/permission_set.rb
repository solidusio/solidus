# frozen_string_literal: true

module Spree
  class PermissionSet < Spree::Base
    has_many :role_permissions
    has_many :roles, through: :role_permissions
    validates :name, :set, presence: true
    scope :display_permissions, -> { where('name LIKE ?', '%Display') }
    scope :management_permissions, -> { where('name LIKE ?', '%Management') }
  end
end
