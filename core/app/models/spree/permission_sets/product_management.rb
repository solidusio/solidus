module Spree
  module PermissionSets
    class ProductManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::Product
        can :manage, Spree::Image
        can :manage, Spree::Variant
        can :manage, Spree::OptionValue
        can :manage, Spree::ProductProperty
        can :manage, Spree::OptionType
        can :manage, Spree::Property
        can :manage, Spree::Prototype
        can :manage, Spree::Taxonomy
        can :manage, Spree::Taxon
        can :manage, Spree::Classification
      end
    end
  end
end
