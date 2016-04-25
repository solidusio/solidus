module OrderFeatureHelper
  def complete_split_to(destination, quantity: nil)
    if destination.is_a?(Spree::Shipment)
      destination = destination.number
    elsif destination.is_a?(Spree::StockLocation)
      destination = destination.name
    end

    select2_no_label(destination, from: 'Choose location')

    if quantity
      fill_in 'item_quantity', with: quantity
    end

    click_icon :ok
  end
end
