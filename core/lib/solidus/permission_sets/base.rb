# frozen_string_literal: true

module Solidus
  module PermissionSets
    # This is the base class used for crafting permission sets.
    #
    # This is used by {Solidus::RoleConfiguration} when adding custom behavior to {Solidus::Ability}.
    # See one of the subclasses for example structure such as {Solidus::PermissionSets::UserDisplay}
    #
    # @see Solidus::RoleConfiguration
    # @see Solidus::PermissionSets
    class Base
      # @param ability [CanCan::Ability]
      #   The ability that will be extended with the current permission set.
      #   The ability passed in must respond to #user
      def initialize(ability)
        @ability = ability
      end

      # Activate permissions on the ability. Put your can and cannot statements here.
      # Must be overriden by subclasses
      def activate!
        raise NotImplementedError.new
      end

      private

      attr_reader :ability
      delegate :can, :cannot, :user, to: :ability
    end
  end
end
