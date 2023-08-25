# frozen_string_literal: true

# @component "ui/toggletip"
class SolidusAdmin::UI::Toggletip::ComponentPreview < ViewComponent::Preview
  DUMMY_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

  include SolidusAdmin::Preview

  def overview
    render_with_template(
      locals: {
        guide: DUMMY_TEXT,
        positions: current_component::POSITIONS.keys,
        themes: current_component::THEMES.keys
      }
    )
  end

  # @param guide text
  # @param position select :position_options
  # @param theme select :theme_options
  def playground(guide: DUMMY_TEXT, position: :up, theme: :light)
    render_with_template(
      locals: {
        guide: guide,
        position: position,
        theme: theme
      }
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
