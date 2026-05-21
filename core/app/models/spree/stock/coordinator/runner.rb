# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      module Runner
        def self.call(middlewares, context)
          chain = middlewares.to_a.reverse.reduce(->(_ctx) {}) { |inner, klass|
            ->(ctx) { klass.new.call(ctx, &inner) }
          }

          chain.call(context)
        end
      end
    end
  end
end
