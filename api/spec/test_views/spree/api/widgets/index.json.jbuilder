
# frozen_string_literal: true

json.widgets(@collection) do |widget|
  json.partial!("spree/api/widgets/widget", widget: widget)
end
json.count @collection.count
json.current_page(params[:page] || 1)
json.pages @collection.total_pages
