# frozen_string_literal: true

module Spree
  class PermissionSet < Spree::Base
    has_many :role_permissions, dependent: :destroy
    has_many :roles, through: :role_permissions
    validates :name, :set, :privilege, :category, presence: true
    scope :display_permissions, -> { where(privilege: "display") }
    scope :management_permissions, -> { where(privilege: "management") }
  end
end
