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

  def column(name, class_name: nil, &block)
    name =
      case name
      when Symbol then @model_class.human_attribute_name(name)
      else name
      end

    @columns << Column.new(name: name, content: block, class_name: class_name)
  end

  Column = Struct.new(:name, :content, :class_name, keyword_init: true)
  private_constant :Column
end
