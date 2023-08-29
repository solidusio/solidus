# frozen_string_literal: true

module SolidusAdmin
  module Form
    module Element
      # Builds a form fieldset component.
      #
      # This class encapsulates a form fieldset definition and its resolution to
      # a component.
      class Fieldset
        # @param elements [Array<#call(form, builder)>] See
        #  {SolidusAdmin::UI::Forms::Form::Component#initialize}.
        # @param component [ViewComponent::Base, nil] the component to be
        #  used when rendering. When `nil`, the component configured in the form
        #  `fieldset_component` keyword argument on initialization is used.
        # @param attributes [Hash] Attributes to pass to the fieldset
        #  component.
        def initialize(elements:, component: nil, **attributes)
          @elements = elements
          @component = component
          @attributes = attributes
        end

        # @api private
        def call(form, builder)
          component_class(form).new(
            **@attributes
          ).with_content(
            render_elements(form, builder)
          )
        end

        private

        def component_class(form)
          @component || form.dependencies[:fieldset]
        end

        def render_elements(form, builder)
          return "" if @elements.empty?

          form.render_elements(@elements, builder)
        end
      end
    end
  end
end
