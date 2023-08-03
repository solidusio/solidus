# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Switch::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: '
      w-8 h-5

      after:w-4 after:h-4
      after:top-0.5 after:left-0.5

      active:after:w-4
      after:checked:left-[1.875rem]
    ',
    m: '
      w-10 h-6

      after:w-5 after:h-5
      after:top-0.5 after:left-0.5

      active:after:w-5
      after:checked:left-[2.375rem]
    ',
  }.freeze

  def initialize(size: :m, **attributes)
    @size = size
    @attributes = attributes
  end

  def call
    tag.input(
      type: 'checkbox',
      class: "
        #{SIZES.fetch(@size)}
        appearance-none	outline-0 cursor-pointer bg-gray-200 inline-block rounded-full relative

        after:content-[''] after:absolute after:bg-white
        after:duration-300 after:rounded-full after:checked:-translate-x-full

        hover:bg-gray-300
        disabled:opacity-40 disabled:cursor-not-allowed
        checked:bg-gray-500 checked:hover:bg-gray-700
      ",
      **@attributes,
    )
  end
end
