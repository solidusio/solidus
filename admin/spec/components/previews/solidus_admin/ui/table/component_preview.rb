# frozen_string_literal: true

# @component "ui/table"
class SolidusAdmin::UI::Table::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # Render a simple table with 10 products.
  # - The first column is the product `#name` attribute, and uses a **symbol** for both the content and the header
  # - The second column is the product `#available_on` attribute, and uses **a block returning strings** for both the content and the header
  # - The third column is the product `#price` attribute, uses **blocks returning component instances** for both the content and the header
  #
  # All these ways to header and data cells can be mixed and matched.
  def simple
    model_class = Spree::Product
    rows = Array.new(10) do |n|
      model_class.new(name: "Product #{n}", price: n * 10.0, available_on: n.days.ago)
    end

    render component("ui/table").new(rows: rows, model_class: model_class).tap { |t|
      t.column(:name) { _1.name }
      t.column(:available_on) { "#{time_ago_in_words _1.available_on} ago" }
      t.column(:price) { component("ui/badge").new(name: _1.display_price, color: :green) }
    }
  end
end
