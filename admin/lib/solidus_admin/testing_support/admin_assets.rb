# frozen_string_literal: true

RSpec.configure do |config|
  config.when_first_matching_example_defined(solidus_admin: true) do
    config.before(:suite) do
      # rubocop:disable Rails/Exit
      system("bin/rails solidus_admin:tailwindcss:build") or abort "Failed to build Tailwind CSS"
      # rubocop:enable Rails/Exit
      Rails.application.precompiled_assets
    end
  end
end
