# frozen_string_literal: true

json.call(zone, :id, :name, :description)
json.zone_members(zone.zone_members) do |zone_member|
  json.call(zone_member, :id, :name, :zoneable_type, :zoneable_id)
end
