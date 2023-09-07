# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Form::Component < SolidusAdmin::BaseComponent
  # @param elements [Array<#call(form, builder)>] Builders of renderable
  #  elements within a form context. They need to implement `#call(form,
  #  builder)`, where the arguments are an instance of this class and an
  #  instance of `ActionView::Helpers::FormBuilder`. The method needs to return
  #  something responding to `#render_in(view_context)`. See the following
  #  classes for examples:
  #  - {SolidusAdmin::Form::Elements::Field}
  #  - {SolidusAdmin::Form::Elements::Fieldset}
  #  - {SolidusAdmin::Form::Elements::Component}
  #  - {SolidusAdmin::Form::Elements::HTML}
  # @param attributes [Hash] Attributes to pass to the Rails `form_with` helper,
  #  which is used to render the form.
  def initialize(elements:, **attributes)
    @elements = elements
    @attributes = attributes
  end

  # @return [Hash{Symbol => SolidusAdmin::BaseComponent}] Hash of component
  #  classes dependencies given on initialization.
  def dependencies
    {
      fieldset: component("ui/forms/fieldset"),
      text_field: component("ui/forms/text_field"),
      text_area: component("ui/forms/text_area")
    }
  end

  # @api private
  def render_elements(elements, builder)
    safe_join(
      elements.map do |element|
        render_element(element, builder)
      end
    )
  end

  # @api private
  def render_element(element, builder)
    render element.call(self, builder)
  end
end
