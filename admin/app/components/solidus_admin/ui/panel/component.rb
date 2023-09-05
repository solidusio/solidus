# frozen_string_literal: true

class SolidusAdmin::UI::Panel::Component < SolidusAdmin::BaseComponent
  renders_one :actions

  # @param title [String] the title of the panel
  # @param title_hint [String] the title hint of the panel
  def initialize(title: nil, title_hint: nil)
    @title = title
    @title_hint = title_hint
  end
end
