json.payments(@payments) { |payment| json.(payment, *payment_attributes) }
json.count(@payments.count)
json.current_page(@payments.current_page)
json.pages(@payments.total_pages)
