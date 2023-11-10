# frozen_string_literal: true

# @component "layout/navigation/account"
class SolidusAdmin::Layout::Navigation::Account::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param user_label text
  def playground(user_label: "Alice Doe")
    render_with_template(
      locals: {
        user_label: user_label
      }
    )
  end
end
