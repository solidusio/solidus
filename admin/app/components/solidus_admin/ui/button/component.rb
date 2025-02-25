# frozen_string_literal: true

class SolidusAdmin::UI::Button::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %{
      h-7 w-7 p-1
      text-xs font-semibold leading-none
    },
    m: %{
      h-9 w-9 p-1.5
      text-sm font-semibold leading-none
    },
    l: %{
      h-12 w-12 p-2
      text-base font-semibold leading-none
    },
  }

  TEXT_PADDINGS = {
    s: %{px-1.5 w-auto},
    m: %{px-3 w-auto},
    l: %{px-4 w-auto},
  }

  ICON_SIZES = {
    s: %{w-[1.4em] h-[1.4em]},
    m: %{w-[1.35em] h-[1.35em]},
    l: %{w-[1.5em] h-[1.5em]},
  }

  SCHEMES = {
    primary: %{
      text-white bg-black
      hover:text-white hover:bg-gray-600
      active:text-white active:bg-gray-800 aria-current:text-white aria-current:bg-gray-800
      focus:text-white focus:bg-gray-700
      disabled:text-gray-400 disabled:bg-gray-100
      aria-disabled:text-gray-400 aria-disabled:bg-gray-100
    },
    secondary: %{
      text-gray-700 bg-white border border-1 border-gray-200
      hover:bg-gray-50
      active:bg-gray-100            aria-current:bg-gray-100
      focus:bg-gray-50
      disabled:text-gray-300 disabled:bg-white
      aria-disabled:text-gray-300 aria-disabled:bg-white
    },
    danger: %{
      text-red-500 bg-white border border-1 border-red-500
      hover:bg-red-500 hover:border-red-600 hover:text-white
      active:bg-red-600 active:border-red-700 active:text-white aria-current:bg-red-600 aria-current:border-red-700 aria-current:text-white
      focus:bg-red-50 focus:bg-red-500 focus:border-red-600 focus:text-white
      disabled:text-red-300 disabled:bg-white disabled:border-red-200
      aria-disabled:text-red-300 aria-disabled:bg-white aria-disabled:border-red-200
    },
    ghost: %{
      text-gray-700 bg-transparent
      hover:bg-gray-50
      active:bg-gray-100 aria-current:bg-gray-100
      focus:bg-gray-50 focus:ring-gray-300 focus:ring-2
      disabled:text-gray-300 disabled:bg-transparent disabled:border-gray-300
      aria-disabled:text-gray-300 aria-disabled:bg-transparent aria-disabled:border-gray-300
    },
  }

  def self.back(path:, **options)
    new(
      tag: :a,
      title: t(".back"),
      icon: "arrow-left-line",
      scheme: :secondary,
      href: path,
      **options
    )
  end

  def self.discard(path:, **options)
    new(
      tag: :a,
      text: t(".discard"),
      scheme: :secondary,
      href: path,
      **options
    )
  end

  def self.save(**options)
    new(text: t(".save"), **options)
  end

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
      'focus:ring focus:ring-gray-300 focus:ring-0.5 focus:ring-offset-0 [&:focus-visible]:outline-none',
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
