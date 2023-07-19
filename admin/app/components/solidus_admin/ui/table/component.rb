# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param page [GearedPagination::Page] The pagination page object.
  # @param path [Proc] A callable object that generates the path for pagination links.
  # @param columns [Array<Hash>] The array of column definitions.
  # @option columns [Symbol|Proc|#to_s] :header The column header.
  # @option columns [Symbol|Proc|#to_s] :data The data accessor for the column.
  # @option columns [String] :class_name (optional) The class name for the column.
  # @param pagination_component [Class] The pagination component class (default: component("ui/table/pagination")).
  def initialize(page:, path: nil, columns: [], pagination_component: component("ui/table/pagination"))
    @page = page
    @path = path
    @columns = columns.map { Column.new(**_1) }
    @pagination_component = pagination_component
    @model_class = page.records.model
    @rows = page.records
  end

  def render_header_cell(cell)
    cell =
      case cell
      when Symbol
        @model_class.human_attribute_name(cell)
      when Proc
        cell.call
      else
        cell
      end

    # Allow component instances as cell content
    cell = cell.render_in(self) if cell.respond_to?(:render_in)

    cell_tag = cell.blank? ? :td : :th

    content_tag(cell_tag, cell, class: %{
      border-b
      border-gray-100
      py-3
      px-4
      text-[#4f4f4f]
      text-left
      text-3.5
      font-[600]
      line-[120%]
    })
  end

  def render_data_cell(cell, data)
    cell =
      case cell
      when Symbol
        data.public_send(cell)
      when Proc
        cell.call(data)
      else
        cell
      end

    # Allow component instances as cell content
    cell = cell.render_in(self) if cell.respond_to?(:render_in)

    content_tag(:td, cell, class: "py-2 px-4")
  end

  def render_table_footer
    if @pagination_component
      tag.tfoot do
        tag.tr do
          tag.td(colspan: @columns.size, class: "py-4") do
            tag.div(class: "flex justify-center") do
              render_pagination_component
            end
          end
        end
      end
    end
  end

  def render_pagination_component
    @pagination_component.new(page: @page, path: @path).render_in(self)
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  private_constant :Column
end
