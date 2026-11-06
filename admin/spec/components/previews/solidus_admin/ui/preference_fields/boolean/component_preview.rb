# frozen_string_literal: true

# @component "ui/preference_fields/boolean"
class SolidusAdmin::UI::PreferenceFields::Boolean::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
