# frozen_string_literal: true

# @component "ui/preference_fields/text"
class SolidusAdmin::UI::PreferenceFields::Text::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
