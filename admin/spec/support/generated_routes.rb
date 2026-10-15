# frozen_string_literal: true

# Redraws the dummy app's routes the way a host app gets them: by running the
# install generator against a routes file that already mounts the main solidus
# engine. Opt in per example or group with `:with_generated_routes`.
module GeneratedRoutes
  # Drawing completely rewrites the routes defined in the dummy app, so this has
  # to include the main solidus route. It is what every spec runs with unless it
  # opts into `:with_generated_routes`.
  def self.draw_default
    DummyApp::Application.routes.draw do
      mount SolidusAdmin::Engine, at: "/admin"
      mount Spree::Core::Engine, at: "/"
    end
  end

  def self.draw
    require "generators/solidus_admin/install/install_generator"

    Dir.mktmpdir("solidus_admin_generated_routes") do |destination_root|
      routes_path = Pathname(destination_root).join("config/routes.rb")
      routes_path.dirname.mkpath
      routes_path.write(<<~RUBY)
        Rails.application.routes.draw do
          mount Spree::Core::Engine, at: "/"
        end
      RUBY

      SolidusAdmin::Generators::InstallGenerator.start(["--quiet"], destination_root:)
      load routes_path.to_s
    end
  end
end

RSpec.configure do |config|
  config.around(:each, :with_generated_routes) do |example|
    GeneratedRoutes.draw
    example.run
  ensure
    GeneratedRoutes.draw_default
  end
end
