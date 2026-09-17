# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"

  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end

  if ENV["GITHUB_ACTIONS"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end

  SimpleCov.command_name("solidus:storefront")
  SimpleCov.merge_timeout(3600)
  SimpleCov.start("rails")
end
