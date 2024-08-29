# frozen_string_literal: true

class SolidusAdmin::UI::Radio::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: "size-4 checked:border-[5px]",
    m: "size-5 checked:border-[6px]"
  }.freeze

  def initialize(size: :m, **attributes)
    @size = size
    @attributes = attributes
    @attributes[:class] = "
      #{SIZES.fetch(@size)}
      appearance-none cursor-pointer outline-none
      rounded-full border-2 border-gray-300 bg-white
      checked:border-gray-700
      hover:border-gray-700 hover:checked:border-gray-500
      focus:ring-2 focus:ring-offset-1 focus:ring-gray-300
      active:ring-2 active:ring-offset-1 active:ring-gray-300
      focus-visible:ring-2 focus-visible:ring-offset-1 focus-visible:ring-gray-300
      disabled:border-gray-300/50 disabled:hover:border-gray-300/50 disabled:active:ring-0 disabled:cursor-not-allowed
      transition-all duration-75 ease-linear
    "
  end

  def call
    tag.input(type: "radio", **@attributes)
  end
end
