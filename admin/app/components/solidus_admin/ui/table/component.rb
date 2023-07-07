# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  def initialize(rows:, model_class:, columns: [])
    @rows = rows
    @model_class = model_class
    @columns = columns.map { Column.new(**_1) }
  end

  def render_cell(cell)
    # Allow component instances as cell content
    if cell.respond_to?(:render_in)
      cell.render_in(self)
    else
      cell
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

    render_cell(cell)
  end

  def render_data_cell(cell, data)
    cell =
      case cell
      when Symbol
        data.public_send(cell)
      when Proc
        cell.call(data)
      end

    render_cell(cell)
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  private_constant :Column
end
