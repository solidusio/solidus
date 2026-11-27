# frozen_string_literal: true

# @component "products/form/filename_info"
class SolidusAdmin::Products::Form::FilenameInfo::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
