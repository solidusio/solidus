# frozen_string_literal: true

json.cache! [I18n.locale, adjustment] do
  json.call(adjustment, *adjustment_attributes)
  json.display_amount(adjustment.display_amount.to_s)
end
