# frozen_string_literal: true

module Spree
  module Core
    module ClassConstantizer
      class Set
        include Enumerable

        def initialize
          @collection = ::Set.new
        end

        def <<(klass)
          @collection << klass.to_s
        end

        def concat(klasses)
          klasses.each do |klass|
            self << klass
          end

          self
        end

        delegate :clear, :empty?, to: :@collection

        def delete(object)
          @collection.delete(object.to_s)
        end

        def each
          @collection.each do |klass|
            yield klass.constantize
          end
        end
      end
    end
  end
end
