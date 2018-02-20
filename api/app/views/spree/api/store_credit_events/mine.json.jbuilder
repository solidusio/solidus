# frozen_string_literal: true

json.store_credit_events(@store_credit_events) do |store_credit_event|
  json.(store_credit_event, *store_credit_history_attributes)
  json.order_number(store_credit_event.order.try(:number))
end
json.partial! 'spree/api/shared/pagination', pagination: @store_credit_events
