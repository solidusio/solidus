# frozen_string_literal: true

module Solidus
  class Role < Solidus::Base
    has_many :role_users, class_name: "Solidus::RoleUser", dependent: :destroy
    has_many :users, through: :role_users

    validates_uniqueness_of :name

    def admin?
      name == "admin"
    end
  end
end
