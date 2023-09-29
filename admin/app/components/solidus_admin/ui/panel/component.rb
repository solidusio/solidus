# frozen_string_literal: true

class SolidusAdmin::UI::Panel::Component < SolidusAdmin::BaseComponent
  renders_one :action, ->(name:, href:, icon: 'add-box-fill', **args) {
    link_to(
      icon_tag(icon, class: 'w-[1.4em] h-[1.4em]') + name,
      href,
      **args,
      class: 'flex gap-1 hover:underline'
    )
  }

  # @param title [String] the title of the panel
  # @param title_hint [String] the title hint of the panel
  def initialize(title: nil, title_hint: nil)
    @title = title
    @title_hint = title_hint
  end
end
