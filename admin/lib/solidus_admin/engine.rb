# frozen_string_literal: true

module SolidusAdmin
  class Engine < ::Rails::Engine
    initializer "solidus_admin.assets" do |app|
      app.config.assets.precompile += %w[solidus_admin_manifest]
    end
  end
end
