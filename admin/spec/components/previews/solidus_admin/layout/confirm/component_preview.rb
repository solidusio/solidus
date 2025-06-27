# frozen_string_literal: true

# @component "ui/modal"
class SolidusAdmin::Layout::Confirm::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # @param title text
  # @param body text
  # @param button text
  def overview(title: "Are you sure?", body: "You are about to delete something. This cannot be undone.", button: "Confirm")
    render_with_template(locals: { title:, body:, button: })
  end
end
