# frozen_string_literal: true

module Spree
  module PermissionSets
    class StockDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockItem
        can :display, Spree::StockLocation
      end
    end
  end
end
