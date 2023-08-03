# frozen_string_literal: true

# @component "ui/forms/switch"
class SolidusAdmin::UI::Forms::Switch::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # **With a form builder**
  #
  # The switch component renders a standalone switch input.
  # If the id attribute is not filled, it will be set as a random string.
  #
  # ```erb
  #   <%= form_for @product do |form| %>
  #     ...
  #     <%= render component('ui/forms/switch').new(
  #       id: "#{form.object_name}-switch",
  #       checked: form.object.accept_tos,
  #     ) %>
  #     ...
  #   <% end %>
  # ```
  #

  def overview
    render_with_template
  end

  # @param size select { choices: [s, m] }
  # @param checked toggle
  # @param disabled toggle
  def playground(size: :m, checked: false, disabled: false)
    render current_component.new(id: 1, size: size.to_sym, checked: checked, disabled: disabled)
  end
end
