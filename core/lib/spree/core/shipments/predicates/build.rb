# frozen_string_literal: true

module Spree
  module Core
    module Shipments
      module Predicates
        class Build
          def self.call(_order)
            true
          end
        end
      end
    end
  end
end
