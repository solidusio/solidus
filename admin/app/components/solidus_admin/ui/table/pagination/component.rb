# frozen_string_literal: true

class SolidusAdmin::UI::Table::Pagination::Component < SolidusAdmin::BaseComponent
  # @param prev_link [String] The link to the previous page.
  # @param next_link [String] The link to the next page.
  #
  # @param button_component [Class] The button component class (default: component("ui/button")).
  def initialize(prev_link: nil, next_link: nil, button_component: component("ui/button"))
    @prev_link = prev_link
    @next_link = next_link
    @button_component = button_component
  end

  def render?
    @prev_link.present? || @next_link.present?
  end
end
