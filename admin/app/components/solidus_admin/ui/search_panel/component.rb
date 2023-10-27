# frozen_string_literal: true

class SolidusAdmin::UI::SearchPanel::Component < SolidusAdmin::BaseComponent
  def initialize(search_placeholder: nil, id: nil, **panel_args)
    @search_placeholder = search_placeholder
    @panel_args = panel_args
    @id = id
  end
end
