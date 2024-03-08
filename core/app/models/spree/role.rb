# frozen_string_literal: true

module Spree
  class Role < Spree::Base
    RESERVED_ROLES = ['admin', 'default'].freeze

    has_many :role_users, class_name: "Spree::RoleUser", dependent: :destroy
    has_many :role_permissions, dependent: :destroy
    has_many :permission_sets, through: :role_permissions
    has_many :users, through: :role_users

    scope :non_base_roles, -> { where.not(name: RESERVED_ROLES) }

    validates_uniqueness_of :name, case_sensitive: true
    validates :name, uniqueness: true
    after_save :assign_permissions

    def admin?
      name == "admin"
    end

    def permission_sets_constantized
      permission_sets.map(&:name).map(&:constantize)
    end

    def assign_permissions
      ::Spree::Config.roles.assign_permissions name, permission_sets_constantized
    end
  end
end
