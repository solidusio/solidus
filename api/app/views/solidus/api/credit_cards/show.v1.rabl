object @credit_card
cache [I18n.locale, root_object]
attributes *creditcard_attributes

child :address do
  extends "solidus/api/addresses/show"
end
