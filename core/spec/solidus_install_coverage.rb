# frozen_string_literal: true

if ENV["COVERAGE"]
  require 'simplecov'
  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end
  SimpleCov.command_name('solidus:install')
  SimpleCov.merge_timeout(3600)
  SimpleCov.start('rails')
end

# When the file is executed directly, run the coverage report
if __FILE__ == $PROGRAM_NAME
  require "simplecov"
  SimpleCov.merge_timeout 3600
  SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  require "simplecov-cobertura"
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  SimpleCov.result.format!
end
