# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  def initialize(rows:, model_class:, columns: [])
    @rows = rows
    @model_class = model_class
    @columns = columns.map { Column.new(**_1) }
  end

  def render_cell(tag, cell, **attrs)
    # Allow component instances as cell content
    content_tag(tag, **attrs) do
      if cell.respond_to?(:render_in)
        cell.render_in(self)
      else
        cell
      end
    end
  end

  def render_header_cell(cell)
    cell =
      case cell
      when Symbol
        @model_class.human_attribute_name(cell)
      when Proc
        cell.call
      end

    cell_tag = cell.blank? ? :td : :th

    render_cell(cell_tag, cell, class: <<~CLASSES)
      border-b
      border-gray-100
      py-3
      px-4
      text-[#4f4f4f]
      text-left
      text-3.5
      font-[600]
      line-[120%]
    CLASSES
  end

  def render_data_cell(cell, data)
    cell =
      case cell
      when Symbol
        data.public_send(cell)
      when Proc
        cell.call(data)
      end

    render_cell(:td, cell, class: "py-2 px-4")
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  private_constant :Column
end
