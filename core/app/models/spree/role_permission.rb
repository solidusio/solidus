# frozen_string_literal: true

module Spree
  class RolePermission < Spree::Base
    belongs_to :role
    belongs_to :permission_set
  end
end
