# frozen_string_literal: true

# @component "ui/preference_fields/integer"
class SolidusAdmin::UI::PreferenceFields::Integer::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
