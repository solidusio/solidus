# frozen_string_literal: true

module SolidusAdmin
  module Form
    module Element
      # Builds a form field component.
      #
      # This class encapsulates a form field definition and its resolution to a
      # component.
      class Field
        # @param component [Symbol, ViewComponent::Base] the component to be
        #  used when rendering. It can be a component class (which needs to
        #  accept the `builder:` parameter on initialization) or a Symbol. When
        #  the latter, it's used to infer the one configured in the form
        #  instance. For instance, for a `:text_field` type, the component used
        #  will be the one given to the form component as the
        #  `text_field_component` keyword argument on initialization.
        # @param attributes [Hash] attributes to pass to the field component.
        def initialize(component:, **attributes)
          @component = component
          @attributes = attributes
        end

        # @api private
        def call(form, builder)
          component_class(form).new(
            builder: builder,
            **@attributes
          )
        end

        private

        def component_class(form)
          case @component
          when Symbol
            form.dependencies[@component]
          else
            @component
          end
        end
      end
    end
  end
end
