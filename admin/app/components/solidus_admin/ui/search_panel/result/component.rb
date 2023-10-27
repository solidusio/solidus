# frozen_string_literal: true

class SolidusAdmin::UI::SearchPanel::Result::Component < SolidusAdmin::BaseComponent
  def call
    tag.div(
      content,
      class: "rounded p-2 hover:bg-gray-25 aria-selected:bg-gray-25 cursor-pointer",
      "data-#{component('ui/search_panel').stimulus_id}-target": "result",
      "data-action": "click->#{component('ui/search_panel').stimulus_id}#clickedResult",
    )
  end
end
