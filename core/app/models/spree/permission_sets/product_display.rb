# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read-only permissions for products.
    #
    # This permission set allows users to view all related information about
    # products, also from the admin panel, including:
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
    class ProductDisplay < PermissionSets::Base
      class << self
        def privilege
          :display
        end

        def category
          :product
        end
      end

      def activate!
        can [:read, :admin, :edit], Spree::Product
        can [:read, :admin], Spree::Image
        can [:read, :admin], Spree::Variant
        can [:read, :admin], Spree::OptionValue
        can [:read, :admin], Spree::ProductProperty
        can [:read, :admin], Spree::OptionType
        can [:read, :admin], Spree::Property
        can [:read, :admin], Spree::Taxonomy
        can [:read, :admin], Spree::Taxon
      end
    end
  end
end
