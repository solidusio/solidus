# frozen_string_literal: true

# @component "ui/toggletip"
class SolidusAdmin::UI::Toggletip::ComponentPreview < ViewComponent::Preview
  DUMMY_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

  include SolidusAdmin::Preview

  def overview
    render_with_template(
      locals: {
        text: DUMMY_TEXT,
        positions: current_component::POSITIONS.keys,
        themes: current_component::THEMES.keys
      }
    )
  end

  # @param text text
  # @param position select :position_options
  # @param theme select :theme_options
  # @param open toggle
  def playground(text: DUMMY_TEXT, position: :down, theme: :light, open: false)
    render current_component.new(
      text: text,
      position: position,
      theme: theme,
      open: open,
      class: "m-80"
    )
  end

  private

  def position_options
    current_component::POSITIONS.keys
  end

  def theme_options
    current_component::THEMES.keys
  end
end
