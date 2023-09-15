# frozen_string_literal: true

class SolidusAdmin::UI::Button::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[
      h-7 w-7 p-1
      text-xs font-semibold leading-none
    ],
    m: %w[
      h-9 w-9 p-1.5
      text-sm font-semibold leading-none
    ],
    l: %w[
      h-12 w-12 p-2
      text-base font-semibold leading-none
    ],
  }

  TEXT_PADDINGS = {
    s: %w[px-1.5 w-auto],
    m: %w[px-3 w-auto],
    l: %w[px-4 w-auto],
  }

  ICON_SIZES = {
    s: %w[w-[1.4em] h-[1.4em]],
    m: %w[w-[1.35em] h-[1.35em]],
    l: %w[w-[1.5em] h-[1.5em]],
  }

  SCHEMES = {
    primary: %w[
      text-white bg-black
      hover:text-white hover:bg-gray-600
      active:text-white active:bg-gray-800
      focus:text-white focus:bg-gray-700
      disabled:text-gray-400 disabled:bg-gray-100 disabled:cursor-not-allowed
      aria-disabled:text-gray-400 aria-disabled:bg-gray-100 aria-disabled:aria-disabled:cursor-not-allowed
    ],
    secondary: %w[
      text-gray-700 bg-white border border-1 border-gray-200
      hover:bg-gray-50
      active:bg-gray-100
      focus:bg-gray-50
      disabled:text-gray-300 disabled:bg-white disabled:cursor-not-allowed
      aria-disabled:text-gray-300 aria-disabled:bg-white aria-disabled:cursor-not-allowed
    ],
    ghost: %w[
      text-gray-700 bg-transparent
      hover:bg-gray-50
      active:bg-gray-100
      focus:bg-gray-50 focus:ring-gray-300 focus:ring-2
      disabled:text-gray-300 disabled:bg-transparent disabled:border-gray-300 disabled:cursor-not-allowed
      aria-disabled:text-gray-300 aria-disabled:bg-transparent aria-disabled:border-gray-300 aria-disabled:cursor-not-allowed
    ],
  }

  def initialize(
    tag: :button,
    text: nil,
    icon: nil,
    size: :m,
    scheme: :primary,
    **attributes
  )
    @tag = tag
    @text = text
    @icon = icon
    @attributes = attributes

    @attributes[:class] = [
      'justify-start items-center justify-center gap-1 inline-flex rounded',
      'focus:ring focus:ring-gray-300 focus:ring-0.5 focus:bg-white focus:ring-offset-0 [&:focus-visible]:outline-none',
      SIZES.fetch(size.to_sym),
      (TEXT_PADDINGS.fetch(size.to_sym) if @text),
      SCHEMES.fetch(scheme.to_sym),
      @attributes[:class],
    ].join(' ')

    @icon_classes = [
      'fill-current',
      ICON_SIZES.fetch(size.to_sym),
    ]
  end

  def call
    content = []
    content << render(component('ui/icon').new(name: @icon, class: @icon_classes)) if @icon
    content << @text if @text

    content_tag(@tag, safe_join(content), **@attributes)
  end
end
