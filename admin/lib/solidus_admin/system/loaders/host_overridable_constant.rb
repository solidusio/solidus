# frozen_string_literal: true

module SolidusAdmin
  module System
    module Loaders
      # Loader that resolves constants that can be overriden by the host.
      #
      # For instance, when the loader is configured like this:
      #
      # ```ruby
      # config.component_dirs.add "app/components" do |dir|
      #  dir.loader = SolidusAdmin::System::Loaders::HostOverridableConstant.method(:call).curry["components"]
      # end
      # ```
      #
      # When `Container["foo"]` is given and the loader is used:
      #
      # - It will return a `MyApp::SolidusAdmin::Foo` constant if `app/components/my_app/solidus_admin/foo.rb` exists.
      # - Otherwise, it will return the resolved constant from the engine.
      #
      # @api private
      class HostOverridableConstant < Dry::System::Loader
        # @param [String] namespace
        def self.call(namespace, component, *_args)
          return override_constant(component) if override_path(namespace, component).exist?

          require!(component)
          constant(component)
        end

        class << self
          private

          def application
            Rails.application
          end

          def application_name
            Rails.application.class.module_parent.name
          end

          def override_path(namespace, component)
            application
              .root
              .join(
                "app",
                namespace,
                application_name.underscore,
                "solidus_admin",
                "#{component.identifier.key}.rb"
              )
          end

          def override_constant(component)
            "#{application_name}::SolidusAdmin::#{component.identifier.key.camelize}".constantize
          end
        end
      end
    end
  end
end
