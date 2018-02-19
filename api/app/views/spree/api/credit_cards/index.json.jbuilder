# frozen_string_literal: true

json.credit_cards(@credit_cards) do |credit_card|
  json.partial!("spree/api/credit_cards/credit_card", credit_card: credit_card)
end
json.partial! 'spree/api/shared/pagination', pagination: @credit_cards
