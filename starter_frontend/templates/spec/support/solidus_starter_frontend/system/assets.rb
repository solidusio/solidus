RSpec.configure do |config|
  config.when_first_matching_example_defined(type: :system) do
    config.before(:suite) do
      # Preload routes before building JS for Rails 8 compatibility.
      Rails.application.try(:reload_routes_unless_loaded)
      system 'bin/rails tailwindcss:build' or abort 'Failed to build Tailwind CSS'
      Rails.application.precompiled_assets
    end
  end
end

