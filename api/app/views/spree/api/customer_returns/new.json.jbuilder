# frozen_string_literal: true

json.attributes([*customer_return_attributes])
json.required_attributes(required_fields_for(Spree::CustomerReturn))
