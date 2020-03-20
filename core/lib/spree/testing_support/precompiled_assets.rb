# frozen_string_literal: true

RSpec.configure do |config|
  config.when_first_matching_example_defined(type: :feature) do
    config.before :suite do
      Rails.application.precompiled_assets
    end
  end

  config.when_first_matching_example_defined(type: :system) do
    config.before :suite do
      Rails.application.precompiled_assets
    end
  end
end
