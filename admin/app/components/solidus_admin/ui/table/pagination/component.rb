# frozen_string_literal: true

class SolidusAdmin::UI::Table::Pagination::Component < SolidusAdmin::BaseComponent
  # @param prev_link [String] The link to the previous page.
  # @param next_link [String] The link to the next page.
  def initialize(prev_link: nil, next_link: nil)
    @prev_link = prev_link
    @next_link = next_link
  end

  def render?
    @prev_link.present? || @next_link.present?
  end

  def link_classes(rounded: nil)
    classes = %w[
      flex
      items-center
      justify-center
      px-2
      h-10
      ml-0
      leading-tight
      text-gray-500
      bg-white
      border
      border-gray-300
      hover:bg-gray-100
      hover:text-gray-700
      dark:bg-gray-800
      dark:border-gray-700
      dark:text-gray-400
      dark:hover:bg-gray-700
      dark:hover:text-white
    ]
    classes << 'rounded-l-lg' if rounded == :left
    classes << 'rounded-r-lg' if rounded == :right
    classes.join(' ')
  end
end
