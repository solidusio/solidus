module Spree
  module Actions
    class Action
      def call
        mutex do
          perform
        end
      end

      private

      # FIXME: waiting on nested mutexes being supported
      def mutex
        yield
      end
    end
  end
end
