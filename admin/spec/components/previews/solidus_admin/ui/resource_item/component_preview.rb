# frozen_string_literal: true

# @component "ui/resource_item"
class SolidusAdmin::UI::ResourceItem::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param thumbnail text
  # @param title text
  # @param subtitle text
  def render_resource_item(title: "Your Title", subtitle: "Your Subtitle", thumbnail: "https://picsum.photos/200/300")
    render current_component.new(
      title: title,
      subtitle: subtitle,
      thumbnail: thumbnail
    )
  end
end
