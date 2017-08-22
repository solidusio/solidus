json.partial! 'spree/api/shared/pagination', pagination: @variants
json.variants(@variants) do |variant|
  json.partial!("spree/api/variants/big", variant: variant)
end
