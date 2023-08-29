# frozen_string_literal: true

module SolidusAdmin
  module Form
    module Element
      # Builds arbitrary HTML in a form.
      #
      # This class can be used to render arbitrary content in a form.
      #
      # This is useful when there's the need to render content that's not
      # strictly related to a form definition, but still needs to be within the
      # form tags. If the content is a component, it's better to use
      # {SolidusAdmin::Form::Element::Component} instead.
      class HTML
        # @param html [String] the HTML to render.
        def initialize(html:)
          @html = html
        end

        # @api private
        def call(_form, _builder)
          self
        end

        # @api private
        def render_in(_view_context)
          @html
        end
      end
    end
  end
end
