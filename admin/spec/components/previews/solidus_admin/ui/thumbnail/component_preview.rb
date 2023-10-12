# frozen_string_literal: true

# @component "ui/thumbnail"
class SolidusAdmin::UI::Thumbnail::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param size select { choices: [s, m, l] }
  # @param src text
  def playground(size: :m, src: "https://picsum.photos/200/300")
    render component("ui/thumbnail").new(size: size.to_sym, src: src)
  end
end
