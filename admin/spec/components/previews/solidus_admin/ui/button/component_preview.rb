# frozen_string_literal: true

# @component "ui/button"
class SolidusAdmin::UI::Button::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # @param text text
  # @param show_icon toggle
  def overview(text: "Button", show_icon: true)
    render_with_template locals: { text: text, show_icon: show_icon }
  end

  # @param size select { choices: [s, m, l] }
  # @param scheme select { choices: [primary, secondary, ghost] }
  # @param icon select "Of all icon names we show only 10, chosen randomly" :icon_options
  # @param text text
  def playground(size: :m, scheme: :primary, text: "Button", icon: 'search-line')
    render component("ui/button").new(size: size, scheme: scheme, text: text, icon: icon.presence)
  end

  private

  def icon_options
    @icon_options ||= ['search-line'] + component('ui/icon')::NAMES.sample(10)
  end
end
