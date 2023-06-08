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
      #  dir.namespaces.add nil, const: "solidus_admin", key: "components"
      # end
      # ```
      #
      # When `Container["foo"]` is given and the loader is used:
      #
      # - It will return a `MyApp::SolidusAdmin::Foo` constant if `app/components/my_app/components/solidus_admin/foo.rb` exists.
      # - Otherwise, it will return the resolved constant from the engine.
      #
      # @api private
      class HostOverridableConstant < Dry::System::Loader
        DIR_SEPARATOR = "/"

        RUBY_EXT = ".rb"

        # @param [String] namespace
        def self.call(namespace, component, *_args)
          return override_constant(component, namespace) if override_path(namespace, component).exist?

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
                component_segment(component, namespace).concat(RUBY_EXT)
              )
          end

          def override_constant(component, namespace)
            "#{application_name}::SolidusAdmin::#{component_segment(component, namespace).classify}".constantize
          end

          # "components.foo.component" => "foo/component"
          def component_segment(component, namespace)
            component
              .identifier
              .namespaced(from: namespace, to: nil)
              .key_with_separator(DIR_SEPARATOR)
          end
        end
      end
    end
  end
end
