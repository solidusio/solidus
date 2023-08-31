# frozen_string_literal: true

module SolidusAdmin
  module Form
    module Element
      # Builds an arbitrary component in a form context.
      #
      # This class can be used to render an arbitrary components in a form.
      #
      # This is useful when there's the need to render a component that's not
      # strictly related to a form definition, but still needs to be within the
      # form tags.
      class Component
        # @param component [ViewComponent::Base] the component instance to
        #   render.
        def initialize(component:)
          @component = component
        end

        # @api private
        def call(_form, _builder)
          @component
        end
      end
    end
  end
end
