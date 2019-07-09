# frozen_string_literal: true

require 'spree/core/environment_extension'

module Spree
  module Backend
    class Environment
      class ProductTabs
        include Spree::Core::EnvironmentExtension

        add_class_set :items
      end
    end
  end
end
