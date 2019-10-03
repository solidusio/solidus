# frozen_string_literal: true

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.verify_partial_doubles = true
  end

  config.around(:each, partial_double_verification: false) do |example|
    without_partial_double_verification do
      example.run
    end
  end
end
