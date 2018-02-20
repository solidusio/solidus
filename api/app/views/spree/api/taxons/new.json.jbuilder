# frozen_string_literal: true

json.attributes([*taxon_attributes])
json.required_attributes(required_fields_for(Spree::Taxon))
