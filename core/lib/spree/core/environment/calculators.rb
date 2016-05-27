module Spree
  module Core
    class Environment
      class Calculators
        include EnvironmentExtension

        add_class_set :shipping_methods
        add_class_set :tax_rates
      end
    end
  end
end
