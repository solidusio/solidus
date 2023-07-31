# frozen_string_literal: true

# @component "ui/table"
class SolidusAdmin::UI::Table::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # Render a simple table with 10 products and pagination.
  # - The `:id` column is the product `#id` attribute, and uses a **symbol** for both the content and the header
  # - The `:name` column is the product `#name` attribute, and uses **a block returning strings** for the content and a symbol for the header
  # - The `:available_on` column is the product `#available_on` attribute, and uses **a block returning strings** for both the content and the header
  # - The `:price` column shows the product `#price` attribute in a badge component, uses **blocks returning component instances** for both the content and the header
  #
  # All these ways to header and data cells can be mixed and matched.
  def simple
    render current_component.new(
      model_class: Spree::Product,
      rows: Array.new(10) {
        Spree::Product.new(id: n, name: "Product #{n}", price: n * 10.0, available_on: n.days.ago)
      },
      columns: [
        { header: :id, data: -> { _1.id.to_s } },
        { header: :name, data: :name },
        { header: -> { "Availability at #{Time.current}" }, data: -> { "#{time_ago_in_words _1.available_on} ago" } },
        { header: -> { component("ui/badge").new(name: "$$$") }, data: -> { component("ui/badge").new(name: _1.display_price, color: :green) } },
        { header: "Generated at", data: Time.current.to_s },
      ],
      prev_page_link: nil,
      next_page_link: '#2',
    )
  end
end
