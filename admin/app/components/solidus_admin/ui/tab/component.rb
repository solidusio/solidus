# frozen_string_literal: true

class SolidusAdmin::UI::Tab::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[h-7 px-1.5 font-semibold text-sm],
    m: %w[h-9 px-3 font-semibold text-sm],
    l: %w[h-12 px-4 font-semibold text-base]
  }

  def initialize(text:, tag: :a, size: :m, current: false, disabled: false, **attributes)
    @tag = tag
    @text = text
    @size = size
    @attributes = attributes

    @attributes[:"aria-current"] = current
    @attributes[:"aria-disabled"] = disabled
    @attributes[:class] = [
      %w[
        rounded justify-start items-center inline-flex py-1.5 cursor-pointer
        bg-transparent text-gray-500

        hover:bg-gray-75 hover:text-gray-700
        focus:bg-gray-25 focus:text-gray-700

        active:bg-gray-75 active:text-black
        aria-current:bg-gray-50 aria-current:text-black

        disabled:bg-gray-75 disabled:text-gray-400
        aria-disabled:bg-gray-75 aria-disabled:text-gray-400
      ],
      SIZES.fetch(@size.to_sym),
      @attributes.delete(:class)
    ].join(" ")
  end

  def call
    content_tag(
      @tag,
      @text,
      **@attributes
    )
  end
end
