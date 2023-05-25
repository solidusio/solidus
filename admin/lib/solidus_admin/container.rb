# frozen_string_literal: true

require "dry/system"
require "dry/system/container"

module SolidusAdmin
  # Global registry for host-injectable components.
  #
  # We use this container to register all the components that can be
  # overridden by the host application.
  #
  # @api private
  class Container < Dry::System::Container
    configure do |config|
      config.root = Pathname(__FILE__).dirname.join("../..").realpath
    end

    # Returns all the registered components for a given namespace.
    def self.within_namespace(namespace)
      keys.filter_map do
        _1.start_with?("#{namespace}#{config.namespace_separator}") && resolve(_1)
      end
    end
  end
end
