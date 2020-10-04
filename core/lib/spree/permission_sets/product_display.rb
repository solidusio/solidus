# frozen_string_literal: true

module Spree
  module PermissionSets
    class ProductDisplay < PermissionSets::Base
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
