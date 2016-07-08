object false
child(@credit_cards => :credit_cards) do
  extends "spree/api/credit_cards/show"
end
node(:count) { @credit_cards.count }
node(:current_page) { @credit_cards.current_page }
node(:pages) { @credit_cards.total_pages }
