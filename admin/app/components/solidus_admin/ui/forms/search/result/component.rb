# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Search::Result::Component < SolidusAdmin::BaseComponent
  def call
    tag.div(
      content,
      class: "rounded p-2 hover:bg-gray-25 aria-selected:bg-gray-25 cursor-pointer",
      "data-#{component('ui/forms/search').stimulus_id}-target": "result",
      "data-action": "click->#{component('ui/forms/search').stimulus_id}#clickedResult",
    )
  end
end
