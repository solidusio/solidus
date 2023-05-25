# frozen_string_literal: true

require "dry/system"
require "dry/system/container"
require "view_component"

module SolidusAdmin
  # Global registry for host-injectable components.
  #
  # We use this container to register all the components that can be
  # overridden by the host application.
  #
  # @api private
  class Container < Dry::System::Container
    class ConstantLoader < Dry::System::Loader
      def self.call(component, *args)
        require!(component)
        constant(component)
      end
    end

    configure do |config|
      config.root = Pathname(__FILE__).dirname.join("../..").realpath
      config.component_dirs.add("app/components") do |dir|
        dir.loader = ConstantLoader
        dir.namespaces.add "solidus_admin", key: nil
      end
    end

    # Returns all the registered components for a given namespace.
    def self.within_namespace(namespace)
      keys.filter_map do
        _1.start_with?("#{namespace}#{config.namespace_separator}") && resolve(_1)
      end
    end
  end
end
