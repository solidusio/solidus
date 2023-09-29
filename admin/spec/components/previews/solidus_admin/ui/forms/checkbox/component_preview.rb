# frozen_string_literal: true

# @component "ui/forms/checkbox"
class SolidusAdmin::UI::Forms::Checkbox::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # **With a form builder**
  #
  # The checkbox component is used to render a checkbox input.
  # It can be used with a Rails form builder by setting the `name` attribute
  # with `forom.object_name`.
  #
  # ```erb
  #   <%= form_for @product do |form| %>
  #     ...
  #     <%= render component('ui/forms/checkbox').new(
  #       name: "#{form.object_name}[accept_tos]",
  #       checked: form.object.accept_tos,
  #     ) %>
  #     ...
  #   <% end %>
  # ```
  #
  # **With stimulus**
  #
  # The checkbox component can be used with stimulus to toggle the `indeterminate`
  # state of the checkbox.
  #
  # ```erb
  #   <%= render component('ui/forms/checkbox').new(
  #     "data-action": "click->#{stimulus_id}#toggleIndeterminate",
  #     "data-#{stimulus_id}-target": "checkbox",
  #   ) %>
  # ```
  #
  # ```js
  #   import { Controller } from "stimulus"
  #
  #   export default class extends Controller {
  #     static targets = ["checkbox"]
  #
  #     toggleIndeterminate() {
  #       this.checkboxTarget.indeterminate = !this.checkboxTarget.indeterminate
  #     }
  #   }
  # ```
  #
  def overview
    render_with_template
  end

  # @param size select { choices: [s, m] }
  # @param checked toggle
  # @param disabled toggle
  def playground(size: :m, checked: false, disabled: false)
    render current_component.new(size: size.to_sym, checked: checked, disabled: disabled)
  end
end
