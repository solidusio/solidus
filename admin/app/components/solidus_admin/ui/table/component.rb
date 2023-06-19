# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  def initialize(rows:, columns:)
    @rows = rows
    @columns = columns
  end

  def self.column(name, &block)
    Column.new(name: name, content: block)
  end

  Column = Struct.new(:name, :content, keyword_init: true)
  private_constant :Column
end
