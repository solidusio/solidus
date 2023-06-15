# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for store administration.
    #
    # This permission set is always added to users with the `:admin` role.
    #
    # It grants permission to perform any read or write action on any resource.
    class SuperUser < PermissionSets::Base
      def activate!
        can :manage, :all
      end
    end
  end
end
