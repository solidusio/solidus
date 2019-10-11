# frozen_string_literal: true

module Solidus
  module PermissionSets
    class ProductManagement < PermissionSets::Base
      def activate!
        can :manage, Solidus::Classification
        can :manage, Solidus::Image
        can :manage, Solidus::OptionType
        can :manage, Solidus::OptionValue
        can :manage, Solidus::Price
        can :manage, Solidus::Product
        can :manage, Solidus::ProductProperty
        can :manage, Solidus::Property
        can :manage, Solidus::Taxon
        can :manage, Solidus::Taxonomy
        can :manage, Solidus::Variant
      end
    end
  end
end
