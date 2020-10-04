# frozen_string_literal: true

json.taxons(@taxons) do |taxon|
  json.id taxon.id
  json.name taxon.name
  json.pretty_name taxon.pretty_name
end
