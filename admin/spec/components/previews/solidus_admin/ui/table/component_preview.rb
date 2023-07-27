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
    model_class = Spree::Product
    rows = Array.new(10) do |n|
      model_class.new(id: n, name: "Product #{n}", price: n * 10.0, available_on: n.days.ago)
    end

    page = Struct.new(:records, :number, :next_param, :first?, :last?).new(rows, 1, '#', true, false)

    page.records.define_singleton_method(:model) do
      model_class
    end

    render_with_template(locals: { page: page, rows: rows })
  end
end
