# frozen_string_literal: true

json.attributes([*product_attributes])
json.required_attributes(required_fields_for(Spree::Product))
