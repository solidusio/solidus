# frozen_string_literal: true

require "solidus_admin/form/element/field"
require "solidus_admin/form/element/fieldset"
require "solidus_admin/form/element/component"
require "solidus_admin/form/element/html"

# @component "ui/forms/form"
class SolidusAdmin::UI::Forms::Form::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # The form component is used to render a form tag along with its content, most
  # commonly form fields.
  #
  # Internally, the
  # [`form_with`](https://edgeapi.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
  # Rails helper is used to render the form tag, and the component will dispatch
  # given arguments to it.
  #
  # The definition of the form is provided from the outside through the
  # `elements` parameter. This parameter is an array of builders of renderable
  # elements, and Solidus Admin provides all the necessary ones to build a form
  # following its UI:
  #
  # ## SolidusAdmin::Form::Element::Field
  #
  # This element renders a form field:
  #
  # ```erb
  # <%=
  #   render components('ui/forms/form',
  #     model: Spree::Product.new,
  #     elements: [
  #       SolidusAdmin::Form::Element::Field.new(
  #         component: :text_field,
  #         field: :name
  #       )
  #     ]
  #   )
  # %>
  # ```
  #
  # The previous example will use the [`text_field`
  # component](../text_field/overview), but you can use any of the available
  # field component.
  #
  # ## SolidusAdmin::Form::Element::Fieldset
  #
  # Wraps a set of fields in a fieldset.
  #
  # You need to provide the inner fields akin to how it's done with the form
  # component. [The fieldet component](../fieldset/overview) is used under the
  # hood, and you can pass any of its attributes through the `attributes`
  # parameter.
  #
  # ```erb
  # <%=
  #   render components('ui/forms/form',
  #     model: Spree::Product.new,
  #     elements: [
  #       SolidusAdmin::Form::Element::Fieldset.new(
  #         elements: [
  #           SolidusAdmin::Form::Element::Field.new(
  #             component: :text_field,
  #             field: :name
  #           )
  #         ],
  #         legend: "Product details",
  #         toggletip_attributes: { guide: "Minimal info", position: :right }
  #       )
  #     ]
  #   )
  # %>
  # ```
  #
  # ## SolidusAdmin::Form::Element::Component
  #
  # This element allows you to render any component inside the form.
  #
  # ```erb
  # <%=
  #   render components('ui/forms/form',
  #     model: Spree::Product.new,
  #     elements: [
  #       SolidusAdmin::Form::Element::Component.new(
  #         component: MyCustomComponent.new
  #       )
  #     ]
  #   )
  # %>
  # ```
  #
  # ## SolidusAdmin::Form::Element::HTML
  #
  # This element allows you to render any HTML inside the form.
  #
  # ```erb
  # <%=
  #   render components('ui/forms/form',
  #     model: Spree::Product.new,
  #     elements: [
  #       SolidusAdmin::Form::Element::HTML.new(
  #         html: "<p>Whatever HTML you want</p>".html_safe
  #       )
  #     ]
  #   )
  # %>
  # ```
  def overview
    render_with_template(
      locals: {
        elements: elements
      }
    )
  end

  private

  def elements
    [
      field_element,
      fieldset_element,
      component_element,
      html_element
    ]
  end

  def field_element
    SolidusAdmin::Form::Element::Field.new(
      component: :text_field,
      field: :name,
      placeholder: "SolidusAdmin::Form::Element::Field",
      errors: {}
    )
  end

  def fieldset_element
    SolidusAdmin::Form::Element::Fieldset.new(
      elements: [
        SolidusAdmin::Form::Element::Field.new(
          component: :text_field,
          field: :name,
          placeholder: "SolidusAdmin::Form::Element::Field",
          errors: {}
        )
      ],
      legend: "SolidusAdmin::Form::Element::Fieldset"
    )
  end

  def component_element
    SolidusAdmin::Form::Element::Component.new(
      component: Class.new(SolidusAdmin::BaseComponent) do
        def self.name
          "MyCustomComponent"
        end

        def call
          tag.p(class: "body-text-bold mb-2 italic") { "SolidusAdmin::Form::Element::Component" }
        end
      end.new
    )
  end

  def html_element
    SolidusAdmin::Form::Element::HTML.new(
      html: "<p class='body-text italic'>SolidusAdmin::Form::Element::HTML</p>".html_safe
    )
  end
end
