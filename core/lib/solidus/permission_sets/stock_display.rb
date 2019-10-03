# frozen_string_literal: true

module Solidus
  module PermissionSets
    class StockDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Solidus::StockItem
        can :display, Solidus::StockLocation
      end
    end
  end
end
