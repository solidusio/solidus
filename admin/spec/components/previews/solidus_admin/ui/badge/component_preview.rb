# frozen_string_literal: true

# @component "ui/badge"
class SolidusAdmin::UI::Badge::ComponentPreview < ViewComponent::Preview
  layout "solidus_admin/preview"
  include SolidusAdmin::ContainerHelper

  # @param name [String]
  def overview(name: "Label")
    render_with_template(locals: { name: name, component: component("ui/badge") })
  end

  # @param name [String]
  # @param color select :color_options
  # @param size select :size_options
  def playground(name: "Label", color: :green, size: :m)
    render component("ui/badge").new(name: name, color: color, size: size)
  end

  private

  def size_options
    component('ui/badge')::SIZES.keys
  end

  def color_options
    component('ui/badge')::COLORS.keys
  end
end
