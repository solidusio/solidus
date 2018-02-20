# frozen_string_literal: true

json.attributes([*taxonomy_attributes])
json.required_attributes(required_fields_for(Spree::Taxonomy))
