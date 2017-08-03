json.credit_cards(@credit_cards) do |credit_card|
  json.partial!("spree/api/credit_cards/credit_card", credit_card: credit_card)
end
json.count(@credit_cards.count)
json.current_page(@credit_cards.current_page)
json.pages(@credit_cards.total_pages)
