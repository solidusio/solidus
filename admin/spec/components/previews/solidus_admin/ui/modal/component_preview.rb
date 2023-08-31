# frozen_string_literal: true

# @component "ui/modal"
class SolidusAdmin::UI::Modal::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def with_text
    render_with_template
  end

  def with_form
    render_with_template
  end

  def with_actions
    render_with_template
  end
end
