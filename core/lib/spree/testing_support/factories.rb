# frozen_string_literal: true

require 'spree/testing_support'

Spree::Deprecation.warn(
  "Please do not try to load factories directly. " \
  'Use factory_bot_rails and rely on the default configuration instead.', caller(1)
)

Spree::TestingSupport.check_factory_bot_version
Spree::TestingSupport.load_all_factories
