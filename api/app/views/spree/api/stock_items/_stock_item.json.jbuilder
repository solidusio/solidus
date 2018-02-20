# frozen_string_literal: true

json.(stock_item, *stock_item_attributes)
json.variant do
  json.partial!("spree/api/variants/small", variant: stock_item.variant)
end
