# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, deprecated_examples: true) do |example|
    Spree::Deprecation.silence do
      example.run
    end
  end
end
