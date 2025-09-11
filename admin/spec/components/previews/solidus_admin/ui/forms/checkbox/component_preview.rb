# frozen_string_literal: true

# @component "ui/forms/checkbox"
class SolidusAdmin::UI::Forms::Checkbox::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # Forms checkbox component utilises regular checkbox component and encapsulates some functionality
  # that is shared between admin forms checkboxes:
  # - adds `hidden_field_tag` to function properly
  # - provides a way to customise label (font size/weight, custom styles)
  # - optionally include a toggletip hint
  #
  # Requires `object_name` and `method` parameters that will form a name of the hidden input and checkbox input fields.
  #
  # Requires `checked` boolean parameter that will be passed directly to `ui/checkbox` component.
  #
  # Accepts and passes along to `ui/checkbox` component every other attribute that is accepted by it, e.g. `size`.
  #
  # ```erb
  #   <%= render component('ui/forms/checkbox').new(object_name: 'stock_location', method: :default, checked: true) do |checkbox| %>
  #     <%= checkbox.with_label(text: "Default") %>
  #     <%= checkbox.with_hint(text: "Will be used by default") %>
  #   <% end %>
  # ```

  def overview
    render_with_template
  end

  # @param caption_size select { choices: [xs, s] }
  # @param caption_weight select { choices: [normal, semibold] }
  # @param caption_classes text
  # @param hint toggle
  # @param hint_text text
  # @param hint_position select { choices: [above, below] }
  def playground(caption_size: :s, caption_weight: :normal, caption_classes: "", hint: true, hint_text: "This will be helpful", hint_position: :above)
    render current_component.new(object_name: "store", method: :active, checked: true) do |component|
      component.with_label(text: "Active", size: caption_size, weight: caption_weight, classes: caption_classes)
      component.with_hint(text: hint_text, position: hint_position) if hint
    end
  end
end
