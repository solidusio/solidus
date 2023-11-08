# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Search::Component < SolidusAdmin::BaseComponent
  def initialize(id: nil, **attributes)
    @id = id
    @attributes = attributes
  end
end
