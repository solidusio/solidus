# frozen_string_literal: true

json.call(taxon, *taxon_attributes)
json.taxons(taxon.children) { |taxon| json.call(taxon, *taxon_attributes) }
