module Spree
  module PermissionSets
    class Base
      def initialize ability
        @ability = ability
      end

      def activate!
        raise NotImplementedError.new
      end

      private

      delegate :can, :cannot, to: :@ability
    end
  end
end
