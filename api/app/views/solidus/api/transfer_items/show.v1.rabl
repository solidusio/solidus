object @transfer_item
attributes *transfer_item_attributes
child(:variant) do
  extends "solidus/api/variants/small"
  attributes *transfer_item_variant_attributes
end
