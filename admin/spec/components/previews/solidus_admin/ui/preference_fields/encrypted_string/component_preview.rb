# frozen_string_literal: true

# @component "ui/preference_fields/encrypted_string"
class SolidusAdmin::UI::PreferenceFields::EncryptedString::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
