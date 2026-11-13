# frozen_string_literal: true

class SolidusAdmin::StockMovements::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def initialize(page:, stock_location:)
    super(page:)
    @stock_location = stock_location
  end

  def model_class
    Spree::StockMovement
  end

  def title
    t(".title", stock_location: @stock_location.name)
  end

  def back_url
    solidus_admin.stock_locations_path
  end

  def search_url
    solidus_admin.stock_location_stock_movements_path(@stock_location)
  end

  def search_key
    :variant_sku_or_variant_product_name_cont
  end

  def columns
    [
      variant_column,
      sku_column,
      quantity_column,
      originated_by_column,
      created_at_column
    ]
  end

  private

  def variant_column
    {
      header: :variant,
      data: ->(stock_movement) do
        variant = stock_movement.stock_item.variant

        safe_join([
          tag.div(variant.name),
          (tag.div(variant.options_text, class: "text-gray-500") if variant.options_text.present?)
        ])
      end
    }
  end

  def sku_column
    {
      header: Spree::Variant.human_attribute_name(:sku),
      data: ->(stock_movement) { stock_movement.stock_item.variant.sku }
    }
  end

  def quantity_column
    {
      header: :quantity,
      data: ->(stock_movement) { tag.span(stock_movement.quantity) }
    }
  end

  def originated_by_column
    {
      header: :originated_by,
      data: ->(stock_movement) { originator_label(stock_movement.originator) }
    }
  end

  def created_at_column
    {
      header: t(".created_at"),
      data: ->(stock_movement) { l(stock_movement.created_at, format: :short) }
    }
  end

  # Mirrors `Spree::Admin::StockMovementsHelper#pretty_originator`: shipments and
  # other numbered records show their number, users show their email.
  def originator_label(originator)
    if originator.respond_to?(:number)
      originator.number
    elsif originator.respond_to?(:email)
      originator.email
    end
  end
end
