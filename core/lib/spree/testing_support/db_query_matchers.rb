# frozen_string_literal: true

require "db-query-matchers"

DBQueryMatchers.configure do |config|
  config.ignores = [/SHOW TABLES LIKE/]
  config.ignore_cached = true
  config.schemaless = true
end
