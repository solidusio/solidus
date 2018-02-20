# frozen_string_literal: true

json.(taxon, *taxon_attributes)
json.taxons(taxon.children) { |taxon| json.(taxon, *taxon_attributes) }
