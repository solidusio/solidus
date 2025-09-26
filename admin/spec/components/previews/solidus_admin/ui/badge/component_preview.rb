# frozen_string_literal: true

# @component "ui/badge"
class SolidusAdmin::UI::Badge::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # @param name text
  def overview(name: "Label")
    render_with_template(locals: {name:})
  end

  # @param name text
  # @param color select :color_options
  # @param size select :size_options
  def playground(name: "Label", color: :green, size: :m)
    render current_component.new(name:, color:, size:)
  end

  private

  def size_options
    current_component::SIZES.keys
  end

  def color_options
    current_component::COLORS.keys
  end
end
