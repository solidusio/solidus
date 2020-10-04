# frozen_string_literal: true

module Spree
  module PermissionSets
    class ProductManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::Classification
        can :manage, Spree::Image
        can :manage, Spree::OptionType
        can :manage, Spree::OptionValue
        can :manage, Spree::Price
        can :manage, Spree::Product
        can :manage, Spree::ProductProperty
        can :manage, Spree::Property
        can :manage, Spree::Taxon
        can :manage, Spree::Taxonomy
        can :manage, Spree::Variant
      end
    end
  end
end
