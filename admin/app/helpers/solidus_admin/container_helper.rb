# frozen_string_literal: true

require "solidus_admin/container"

module SolidusAdmin
  module ContainerHelper
    ComponentNotFoundError = Class.new(StandardError)

    def container
      SolidusAdmin::Container
    end

    def component(name)
      name = name.tr('/', '.')

      container.resolve("components.#{name}.component")
    rescue Dry::Core::Container::KeyError => e
      raise ComponentNotFoundError, e.message.gsub(/\bcomponents\.([\w.]+)\.component\b/) { $1.tr('.', '/') }
    end
  end
end
