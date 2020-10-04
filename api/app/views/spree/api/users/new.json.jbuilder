# frozen_string_literal: true

json.attributes([*user_attributes])
json.required_attributes(required_fields_for(Spree.user_class))
