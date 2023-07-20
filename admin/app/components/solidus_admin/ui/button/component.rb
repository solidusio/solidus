# frozen_string_literal: true

class SolidusAdmin::UI::Button::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[
      h-7 px-1.5 py-1
      text-xs font-semibold leading-none
    ],
    m: %w[
      h-9 px-3 py-1.5
      text-sm font-semibold leading-none
    ],
    l: %w[
      h-12 px-4 py-2
      text-base font-semibold leading-none
    ],
  }

  SCHEMES = {
    primary: %w[
      text-white bg-black rounded
      hover:text-white hover:bg-gray-600
      active:text-white active:bg-gray-800
      focus:text-white focus:bg-gray-700
      disabled:text-gray-400 disabled:bg-gray-100 disabled:cursor-not-allowed
    ],
    secondary: %w[
      text-gray-700 bg-white border border-1 rounded border-gray-200
      hover:bg-gray-50
      active:bg-gray-100
      focus:bg-gray-50
      disabled:text-gray-300 disabled:bg-white border-gray-200 disabled:cursor-not-allowed
    ],
    ghost: %w[
      text-gray-700 bg-transparent rounded
      hover:bg-gray-50
      active:bg-gray-100
      focus:bg-gray-50 focus:ring-gray-300 focus:ring-2
      disabled:text-gray-300 disabled:bg-transparent border-gray-300 disabled:cursor-not-allowed
    ],
  }

  def initialize(tag: :button, text: nil, class_name: nil, size: :m, scheme: :primary, **attributes)
    @tag = tag
    @text = text
    @attributes = attributes

    @class_name = [
      class_name,
      'justify-start items-center gap-1 inline-flex',
      SIZES.fetch(size.to_sym),
      SCHEMES.fetch(scheme.to_sym),
    ].join(' ')
  end

  def call
    content_tag(@tag, @text, class: @class_name, **@attributes)
  end
end
