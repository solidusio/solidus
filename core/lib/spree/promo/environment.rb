module Spree
  module Promo
    class Environment
      include Core::EnvironmentExtension

      add_class_set :rules
      add_class_set :actions
    end
  end
end
