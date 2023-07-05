# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  def initialize(rows:, model_class:)
    @rows = rows
    @model_class = model_class
    @columns = []
  end

  def self.build_for(rows, **args, &block)
    new(rows: rows, **args).tap(&block)
  end

  def column(name, content = nil, class_name: nil, &block)
    raise ArgumentError, "content and block are mutually exclusive" if content && block

    content ||= block # if a block is passed, use it as the content
    content ||= name if name.is_a?(Symbol) # if a symbol is passed, use it as the method name

    @columns << Column.new(name: name, content: content, class_name: class_name)
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

  Column = Struct.new(:name, :content, :class_name, keyword_init: true)
  private_constant :Column
end
