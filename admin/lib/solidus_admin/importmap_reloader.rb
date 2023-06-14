# frozen_string_literal: true

class SolidusAdmin::ImportmapReloader
  delegate :execute_if_updated, :execute, :updated?, to: :updater

  def reload!
    importmap_paths.each { |path| SolidusAdmin.importmap.draw(path) }
  end

  private

  def importmap_paths
    SolidusAdmin::Config.importmap_paths
  end

  def updater
    @updater ||= Rails.application.config.file_watcher.new(importmap_paths) { reload! }
  end
end
