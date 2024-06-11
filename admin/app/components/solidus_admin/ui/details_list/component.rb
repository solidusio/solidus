# frozen_string_literal: true

class SolidusAdmin::UI::DetailsList::Component < SolidusAdmin::BaseComponent
  def initialize(items:)
    @items = items
  end
end
