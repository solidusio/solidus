# frozen_string_literal: true

# @component "ui/toggletip"
class SolidusAdmin::UI::Toggletip::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param text text
  # @param position select :position_options
  # @param open toggle
  def playground(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", position: :above, open: false)
    render current_component.new(
      text: text,
      position: position,
      open: open,
      class: "m-40"
    )
  end

  private

  def position_options
    current_component::POSITIONS.keys
  end
end
