# frozen_string_literal: true

# @component "ui/forms/fieldset"
class SolidusAdmin::UI::Forms::Fieldset::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # The fieldset component is used to render a set of fields in a form.
  #
  # Most commonly, it'll be used indirectly through the definition given to a
  # [form component](../form/overview).
  #
  # For standalone usage, it wraps the yielded content in a fieldset tag:
  #
  # ```erb
  # <%= render components('ui/forms/fieldset').new do %>
  #   <%= # ... %>
  # <% end %>
  # ```
  #
  # The legend of the fieldset can be set with the `legend` option:
  #
  # ```erb
  # <%= render components('ui/forms/fieldset').new(
  #   legend: "My fieldset"
  # ) do %>
  #   <%= # ... %>
  # <% end %>
  # ```
  #
  # Lastly, a toggletip can be added to the legend with the
  # `toggletip_attributes`, which will be passed to the [toggletip
  # component](../../toggletip):
  #
  # ```erb
  # <%= render components('ui/forms/fieldset').new(
  #   legend: "My fieldset",
  #   toggletip_attributes: {
  #     text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  #     position: :right
  #   }
  # ) do %>
  #  <%= # ... %>
  # <% end %>
  # ```
  def overview
  end
end
