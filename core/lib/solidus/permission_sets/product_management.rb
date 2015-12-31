module Solidus
  module PermissionSets
    class ProductManagement < PermissionSets::Base
      def activate!
        can :manage, Solidus::Product
        can :manage, Solidus::Image
        can :manage, Solidus::Variant
        can :manage, Solidus::OptionValue
        can :manage, Solidus::ProductProperty
        can :manage, Solidus::OptionType
        can :manage, Solidus::Property
        can :manage, Solidus::Prototype
        can :manage, Solidus::Taxonomy
        can :manage, Solidus::Taxon
        can :manage, Solidus::Classification
      end
    end
  end
end
