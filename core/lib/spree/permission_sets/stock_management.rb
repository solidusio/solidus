# frozen_string_literal: true

module Spree
  module PermissionSets
    class StockManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockItem
        can :read, Spree::StockLocation
      end
    end
  end
end
