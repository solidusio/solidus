# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for product management.
    #
    # This permission set grants full control over all product and related resources,
    # including:
    #
    # - Products
    # - Images
    # - Variants
    # - Option values
    # - Product properties
    # - Option types
    # - Properties
    # - Taxonomies
    # - Taxons
    # - Classifications
    # - Prices
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
