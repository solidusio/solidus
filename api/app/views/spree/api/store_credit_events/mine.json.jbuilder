json.store_credit_events(@store_credit_events) do |store_credit_event|
  json.(store_credit_event, *store_credit_history_attributes)
  json.order_number(store_credit_event.order.try(:number))
end
json.count(@store_credit_events.count)
json.current_page(@store_credit_events.current_page)
json.pages(@store_credit_events.total_pages)
