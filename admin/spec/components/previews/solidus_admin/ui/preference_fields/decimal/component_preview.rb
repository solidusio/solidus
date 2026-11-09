# frozen_string_literal: true

# @component "ui/preference_fields/decimal"
class SolidusAdmin::UI::PreferenceFields::Decimal::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
