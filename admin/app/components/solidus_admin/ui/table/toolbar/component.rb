# frozen_string_literal: true

class SolidusAdmin::UI::Table::Toolbar::Component < SolidusAdmin::BaseComponent
  def initialize(**options)
    @options = options
  end

  def call
    tag.div(
      content,
      **@options,
      class: "
        h-14 p-2 bg-white border-b border-gray-100
        justify-start items-center gap-2
        visible:flex hidden:hidden
        rounded-t-lg
        #{@options[:class]}
      "
    )
  end
end
