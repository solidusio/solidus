# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Switch::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: "w-8 h-5 after:w-4 after:h-4 after:checked:translate-x-3",
    m: "w-10 h-6 after:w-5 after:h-5 after:checked:translate-x-4"
  }.freeze

  def initialize(size: :m, include_hidden: false, **attributes)
    @size = size
    @attributes = attributes
    @include_hidden = include_hidden
    @attributes[:class] = "
      #{SIZES.fetch(@size)}
      rounded-full after:rounded-full
      appearance-none	inline-block relative p-0.5 cursor-pointer

      outline-none
      focus:ring focus:ring-gray-300 focus:ring-0.5 focus:ring-offset-1
      active:ring active:ring-gray-300 active:ring-0.5 active:ring-offset-1

      disabled:cursor-not-allowed
      after:top-0 after:left-0
      after:content-[''] after:block
      after:transition-all after:duration-300 after:ease-in-out

      bg-gray-200 after:bg-white
      hover:bg-gray-300
      checked:bg-gray-500 checked:hover:bg-gray-70
      disabled:opacity-40
      #{attributes[:class]}
    "
  end

  def call
    input = tag.input(
      type: "checkbox",
      **@attributes
    )

    @include_hidden ? hidden_field_tag(@attributes.fetch(:name), false) + input : input
  end
end
