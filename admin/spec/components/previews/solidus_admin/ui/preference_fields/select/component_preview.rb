# frozen_string_literal: true

# @component "ui/preference_fields/select"
class SolidusAdmin::UI::PreferenceFields::Select::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
