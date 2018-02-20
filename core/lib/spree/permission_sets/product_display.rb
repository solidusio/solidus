# frozen_string_literal: true

module Spree
  module PermissionSets
    class ProductDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit], Spree::Product
        can [:display, :admin], Spree::Image
        can [:display, :admin], Spree::Variant
        can [:display, :admin], Spree::OptionValue
        can [:display, :admin], Spree::ProductProperty
        can [:display, :admin], Spree::OptionType
        can [:display, :admin], Spree::Property
        can [:display, :admin], Spree::Taxonomy
        can [:display, :admin], Spree::Taxon
      end
    end
  end
end
