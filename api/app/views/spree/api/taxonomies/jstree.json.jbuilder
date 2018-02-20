# frozen_string_literal: true

json.data @taxonomy.root.name
json.attr do
  json.id @taxonomy.root.id
  json.name @taxonomy.root.name
end
json.state "closed"
