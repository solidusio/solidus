# frozen_string_literal: true

module Spree
  module PermissionSets
    class StockDisplay < PermissionSets::Base
      def activate!
        can [:read, :admin], Spree::StockItem
        can :read, Spree::StockLocation
      end
    end
  end
end
