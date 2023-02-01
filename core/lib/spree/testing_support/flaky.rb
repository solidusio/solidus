# frozen_string_literal: true
require 'rspec/retry'

# Usage:
#
# it 'fails intermittently', :flaky do
#   ...
# end
#
# Docs: https://github.com/NoRedInk/rspec-retry
RSpec.configure do |config|
  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.around(:each, :flaky) do |example|
    if ENV['CI']
      example.run_with_retry retry: 2
    end
  end
end
