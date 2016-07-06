object false

child(@store_credit_events => :store_credit_events) do
  attributes *store_credit_history_attributes
  node(:order_number) { |event| event.order.try(:number) }
end

node(:count) { @store_credit_events.count }
node(:current_page) { @store_credit_events.current_page }
node(:pages) { @store_credit_events.total_pages }
