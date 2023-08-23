# frozen_string_literal: true

# @component "ui/feedback"
class SolidusAdmin::Feedback::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
