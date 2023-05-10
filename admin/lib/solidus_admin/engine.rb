# frozen_string_literal: true

module SolidusAdmin
  class Engine < ::Rails::Engine
    config.after_initialize do |app|
      components_dir = SolidusAdmin::Engine.root.join('app/views/solidus_admin/components').to_s
      helpers_loader = Zeitwerk::Loader.new
      helpers_loader.push_dir(components_dir, namespace: SolidusAdmin::Components)
      helpers_loader.enable_reloading # you need to opt-in before setup
      helpers_loader.setup

      app.config.file_watcher.new [], components_dir => ["rb"] do
        helpers_loader.reload
      end.tap do |reloader|
        app.reloaders << reloader
        app.reloader.to_run { reloader.execute_if_updated { require_unload_lock! } }
      end

      app.config.file_watcher.new [], components_dir => ["i18n.yml", "i18n.yaml"] do
        I18n.reload!
      end.tap do |reloader|
        app.reloaders << reloader
        app.reloader.to_run { reloader.execute_if_updated { require_unload_lock! } }
      end
    end
  end
end
