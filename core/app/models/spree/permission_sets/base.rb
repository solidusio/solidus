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

      attr_reader :ability
      delegate :can, :cannot, :user, to: :ability
    end
  end
end
