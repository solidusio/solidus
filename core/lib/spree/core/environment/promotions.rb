# frozen_string_literal: true

module Spree
  module Core
    class Environment
      class Promotions
        include EnvironmentExtension

        add_class_set :rules
        add_class_set :actions
        add_class_set :shipping_actions
      end
    end
  end
end
