json.cache! [I18n.locale, credit_card] do
  json.(credit_card, *creditcard_attributes)
  json.address do
    if credit_card.address
      json.partial!("spree/api/addresses/address", address: credit_card.address)
    end
  end
end
