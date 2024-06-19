# frozen_string_literal: true

RSpec.configure do |config|
  config.when_first_matching_example_defined(solidus_admin: true) do
    config.before(:suite) do
      system('bin/rails solidus_admin:tailwindcss:build') or abort 'Failed to build Tailwind CSS'
      Rails.application.precompiled_assets
    end
  end
end
