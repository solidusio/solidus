# frozen_string_literal: true

require 'spree/testing_support/factory_bot'

Spree::Deprecation.warn(
  "Please do not try to load factories directly. " \
  'Use factory_bot_rails and rely on the default configuration instead.', caller(1)
)

Spree::TestingSupport::FactoryBot.check_version
Spree::TestingSupport::FactoryBot::PATHS.each { |path| require path }

