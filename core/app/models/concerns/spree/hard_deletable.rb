# frozen_string_literal: true

module Spree
  # Implements all of the methods that Discard implements, but without a deleted_at column.
  # Deprecates all usages of Discard methods.
  module HardDeletable
    extend ActiveSupport::Concern

    def discarded? = false
    def undiscarded? = true
    def kept? = true
    def deleted_at = nil

    included do
      def self.kept
        all
      end

      def self.discarded
        none
      end

      def self.discard_all
        destroy_all
      end

      def self.with_discarded
        all
      end
      class << self
        deprecate :kept, :discarded, :with_discarded, :discard_all, deprecator: Spree.deprecator
      end

      alias_method :discard, :destroy
      alias_method :discard!, :destroy

      deprecate :discard, :discard!, deprecator: Spree.deprecator
      deprecate :discarded?, :undiscarded?, :kept?, :deleted_at, deprecator: Spree.deprecator
    end
  end
end
