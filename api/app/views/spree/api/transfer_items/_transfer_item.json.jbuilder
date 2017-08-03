json.(transfer_item, *transfer_item_attributes)
json.variant do
  json.partial!("spree/api/variants/small", variant: transfer_item.variant)
  json.(transfer_item.variant, *transfer_item_variant_attributes)
end
