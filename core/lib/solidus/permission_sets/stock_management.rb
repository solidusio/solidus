# frozen_string_literal: true

module Solidus
  module PermissionSets
    class StockManagement < PermissionSets::Base
      def activate!
        can :manage, Solidus::StockItem
        can :display, Solidus::StockLocation
      end
    end
  end
end
