# frozen_string_literal: true

module SolidusAdmin
  class Engine < ::Rails::Engine
    config.after_initialize do |app|
      app.config.file_watcher.new [], "#{Engine.root}/app/views/solidus_admin/components" => ["i18n.yml", "i18n.yaml"] do
        I18n.reload!
      end.tap do |reloader|
        app.reloaders << reloader
        app.reloader.to_run do
          reloader.execute_if_updated { require_unload_lock! }
        end
      end
    end
  end
end
