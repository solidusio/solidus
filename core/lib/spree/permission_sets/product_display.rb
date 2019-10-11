# frozen_string_literal: true

module Solidus
  module PermissionSets
    class ProductDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit], Solidus::Product
        can [:display, :admin], Solidus::Image
        can [:display, :admin], Solidus::Variant
        can [:display, :admin], Solidus::OptionValue
        can [:display, :admin], Solidus::ProductProperty
        can [:display, :admin], Solidus::OptionType
        can [:display, :admin], Solidus::Property
        can [:display, :admin], Solidus::Taxonomy
        can [:display, :admin], Solidus::Taxon
      end
    end
  end
end
