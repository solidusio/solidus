# frozen_string_literal: true

# @component "ui/preference_fields/password"
class SolidusAdmin::UI::PreferenceFields::Password::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
