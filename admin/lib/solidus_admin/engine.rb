# frozen_string_literal: true

module SolidusAdmin
  class Engine < ::Rails::Engine
    isolate_namespace SolidusAdmin

    config.before_initialize do
      require "solidus_admin/configuration"
    end

    initializer "solidus_admin.assets" do |app|
      app.config.assets.precompile += %w[solidus_admin/application.css]
    end
  end
end
