object @stock_item
attributes *stock_item_attributes
child(:variant) do
  extends "solidus/api/variants/small"
end
