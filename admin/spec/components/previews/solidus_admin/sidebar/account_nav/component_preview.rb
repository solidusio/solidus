# frozen_string_literal: true

# @component "sidebar/account_nav"
class SolidusAdmin::Sidebar::AccountNav::ComponentPreview < ViewComponent::Preview
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
