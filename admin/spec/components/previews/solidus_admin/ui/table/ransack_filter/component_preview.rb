# frozen_string_literal: true

# @component "ui/table/ransack_filter"
class SolidusAdmin::UI::Table::RansackFilter::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param presentation
  # @param search_bar select { choices: [[ Yes, 10], [ No, 3]] }
  def playground(presentation: "Filter", search_bar: 10)
    render current_component.new(
      presentation: presentation,
      combinator: 'or',
      attribute: "attribute",
      predicate: "eq",
      options: Array.new(search_bar.to_i) { |o| [o, 0] },
      index: 0,
      form: "id"
    )
  end
end
