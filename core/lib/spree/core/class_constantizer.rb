# frozen_string_literal: true

module Spree
  module Core
    module ClassConstantizer
      class Set
        include Enumerable

        def initialize
          @collection = ::Set.new
        end

        def add(klass)
          @collection << klass.to_s
        end
        alias << add

        def concat(klasses)
          klasses.each do |klass|
            self << klass
          end
        end

        delegate :clear, :delete, :empty?, to: :@collection

        def each
          @collection.each do |klass|
            yield klass.constantize
          end
        end
      end
    end
  end
end
