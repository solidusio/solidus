# frozen_string_literal: true

module OrderFeatureHelper
  def add_line_item(product_name, quantity: 1)
    find(".js-add-line-item:not([disabled]), .line-item [name=quantity]").click

    targetted_select2_search product_name, from: ".select-variant"
    fill_in "quantity", with: quantity
    click_icon 'ok'
  end

  def complete_split_to(destination, quantity: nil)
    if destination.is_a?(Spree::Shipment)
      destination = destination.number
    elsif destination.is_a?(Spree::StockLocation)
      destination = destination.name
    end

    select2_no_label(destination, from: 'Choose Location')

    if quantity
      fill_in 'item_quantity', with: quantity
    end

    click_icon :ok
  end
end
