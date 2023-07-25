# frozen_string_literal: true

# @component "ui/icon"
class SolidusAdmin::UI::Icon::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param name select "Of all icon names we show only 10, chosen randomly" :name_options
  def playground(name: name_options.first)
    render component("ui/icon").new(name: name, class: 'w-10 h-10')
  end

  private

  def name_options
    @name_options ||= current_component::NAMES.sample(10)
  end
end
