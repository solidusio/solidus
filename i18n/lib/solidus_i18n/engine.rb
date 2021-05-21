# frozen_string_literal: true

require 'spree/core'

module SolidusI18n
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_i18n'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
