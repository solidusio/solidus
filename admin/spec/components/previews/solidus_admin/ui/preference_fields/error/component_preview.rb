# frozen_string_literal: true

# @component "ui/preference_fields/error"
class SolidusAdmin::UI::PreferenceFields::Error::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
