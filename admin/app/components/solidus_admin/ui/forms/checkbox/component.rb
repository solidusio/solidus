# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Checkbox::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: 'w-4 h-4',
    m: 'w-5 h-5',
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
        cursor-pointer
        disabled:cursor-not-allowed

        bg-white rounded border border-2 border-gray-300
        hover:border-gray-700
        disabled:border-gray-300

        checked:border-gray-700 checked:bg-gray-700 checked:text-white
        checked:hover:border-gray-500 checked:hover:bg-gray-500
        checked:disabled:border-gray-300 checked:disabled:bg-gray-300

        indeterminate:border-gray-700 indeterminate:bg-gray-700 indeterminate:text-white
        indeterminate:hover:border-gray-500 indeterminate:hover:bg-gray-500
        indeterminate:disabled:border-gray-300 indeterminate:disabled:bg-gray-300
      ",
      **@attributes,
    )
  end
end
