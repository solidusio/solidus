# frozen_string_literal: true

require "active_support/core_ext/module"

module Spree
  module Core
    module ClassConstantizer
      # Ordered, array-backed companion to {ClassConstantizer::Set}.
      #
      # Stores class references as strings and constantizes them lazily on
      # iteration, so entries survive code reloading in development. Unlike
      # {ClassConstantizer::Set}, order is preserved.
      class List
        include Enumerable

        def initialize
          @collection = []
        end

        def <<(klass)
          @collection << klass.to_s
          self
        end

        def concat(klasses)
          klasses.each { |klass| self << klass }
          self
        end

        def each
          @collection.each { |klass| yield klass.constantize }
        end

        # Inserts one or more entries immediately before the anchor.
        #
        # @raise [ArgumentError] if the anchor is not in the list.
        def insert_before(anchor, *klasses)
          index = index_for(anchor) or
            raise ArgumentError, "#{anchor} not found in #{self.class}"
          @collection.insert(index, *klasses.map(&:to_s))
          self
        end

        # Inserts one or more entries immediately after the anchor.
        #
        # @raise [ArgumentError] if the anchor is not in the list.
        def insert_after(anchor, *klasses)
          index = index_for(anchor) or
            raise ArgumentError, "#{anchor} not found in #{self.class}"
          @collection.insert(index + 1, *klasses.map(&:to_s))
          self
        end

        def delete(object)
          @collection.delete(object.to_s)
        end

        private

        def index_for(object)
          @collection.index(object.to_s)
        end
      end
    end
  end
end
