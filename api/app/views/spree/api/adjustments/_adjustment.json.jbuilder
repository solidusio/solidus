json.cache! [I18n.locale, adjustment] do
  json.(adjustment, *adjustment_attributes)
  json.display_amount(adjustment.display_amount.to_s)
end
