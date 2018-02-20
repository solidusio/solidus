# frozen_string_literal: true

json.array!(@taxon.children) do |taxon|
  json.data taxon.name
  json.attr do
    json.id taxon.id
    json.name taxon.name
  end
  json.state "closed"
end
