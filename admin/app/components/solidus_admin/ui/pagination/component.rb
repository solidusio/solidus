# frozen_string_literal: true

class SolidusAdmin::UI::Pagination::Component < SolidusAdmin::BaseComponent
  # @param page [GearedPagination::Page] The Geared Pagination page object
  # @param path [Proc] (optional) A callable object that generates the path,
  #                         e.g. ->(page_number){ products_path(page: page_number) }
  def initialize(page:, path: nil)
    @page = page
    @path = path || default_path
  end

  def default_path
    model_name = @page.records.model.model_name.param_key
    lambda { |page_number| send("#{model_name.pluralize}_path", page: page_number) }
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
