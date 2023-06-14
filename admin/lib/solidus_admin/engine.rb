# frozen_string_literal: true

require "view_component"
require "solidus_admin/container"

module SolidusAdmin
  class Engine < ::Rails::Engine
    isolate_namespace SolidusAdmin

    config.before_initialize do
      require "solidus_admin/configuration"
    end

    initializer "solidus_admin.assets" do |app|
      app.config.assets.precompile += %w[solidus_admin_manifest.js]
    end

    initializer "solidus_admin.main_nav_items_provider" do
      require "solidus_admin/system/providers/main_nav"

      Container.start("main_nav")
    end
  end
end
