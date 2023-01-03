# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, silence_deprecations: true) do |example|
    Spree::Deprecation.silence do
      example.run
    end
  end
end

