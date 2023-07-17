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

  def initialize(text:, size: :m, tag: :a, disabled: false, active: false, **attributes)
    @tag = tag
    @text = text
    @size = size
    @active = active
    @disabled = disabled
    @attributes = attributes
  end

  def call
    class_name = [
      @attributes.delete(:class),
      SIZES.fetch(@size.to_sym),
      %w[
        rounded justify-start items-center inline-flex py-1.5 cursor-pointer
        bg-transparent text-gray-500

        hover:bg-gray-75 hover:text-gray-700
        focus:bg-gray-25 focus:text-gray-700

        active:bg-gray-50 active:text-black
        data-[ui-active]:bg-gray-50 data-[ui-active]:text-black

        disabled:bg-gray-100 disabled:text-gray-400
        data-[ui-disabled]:bg-gray-100 data-[ui-disabled]:text-gray-400
      ]
    ].join(" ")

    @attributes["data-ui-active"] = true if @active
    @attributes["data-ui-disabled"] = true if @disabled
    @attributes[:disabled] = true if @disabled && @tag == :button

    content_tag(
      TAG_NAMES.fetch(@tag.to_sym),
      @text,
      class: class_name,
      **@attributes
    )
  end
end
