# frozen_string_literal: true

# @component "ui/table"
class SolidusAdmin::UI::Table::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # Render a simple table with 10 products.
  # - The `:id` column is the product `#id` attribute, and uses a **symbol** for both the content and the header
  # - The `:name` column is the product `#name` attribute, and uses **a block returning strings** for the content and a symbol for the header
  # - The `:available_on` column is the product `#available_on` attribute, and uses **a block returning strings** for both the content and the header
  # - The `:price` column shows the product `#price` attribute in a badge component, uses **blocks returning component instances** for both the content and the header
  #
  # All these ways to header and data cells can be mixed and matched.
  def simple
    model_class = Spree::Product
    rows = Array.new(10) do |n|
      model_class.new(name: "Product #{n}", price: n * 10.0, available_on: n.days.ago)
    end

    render component("ui/table").new(rows: rows, model_class: model_class).tap { |t|
      t.column(:id)
      t.column(:name) { _1.name }
      t.column(-> { "Availability at #{Time.current}" }, -> { "#{time_ago_in_words _1.available_on} ago" })
      t.column(-> { component("ui/badge").new(name: "$$$") }, -> { component("ui/badge").new(name: _1.display_price, color: :green) })
    }
  end
end
