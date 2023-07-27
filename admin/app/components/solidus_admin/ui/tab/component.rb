# frozen_string_literal: true

class SolidusAdmin::UI::Tab::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[h-7 px-1.5 body-small-bold],
    m: %w[h-9 px-3 body-small-bold],
    l: %w[h-12 px-4 body-text-bold],
  }

  TAG_NAMES = {
    a: :a,
    button: :button,
  }

  def initialize(text:, size: :m, tag: :a, **attributes)
    @tag = tag
    @text = text
    @size = size
    @attributes = attributes

    @attributes[:class] = [
      %w[
        rounded justify-start items-center inline-flex py-1.5 cursor-pointer
        bg-transparent text-gray-500

        hover:bg-gray-75 hover:text-gray-700
        focus:bg-gray-25 focus:text-gray-700

        active:bg-gray-50 active:text-black
        aria-current:bg-gray-50 aria-current:text-black

        disabled:bg-gray-100 disabled:text-gray-400
        aria-disabled:bg-gray-100 aria-disabled:text-gray-400
      ],
      SIZES.fetch(@size.to_sym),
      @attributes.delete(:class),
    ].join(" ")
  end

  def call
    content_tag(
      TAG_NAMES.fetch(@tag.to_sym),
      @text,
      **@attributes
    )
  end
end
