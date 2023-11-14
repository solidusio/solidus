# frozen_string_literal: true

class SolidusAdmin::Layout::Feedback::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
