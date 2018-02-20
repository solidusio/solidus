# frozen_string_literal: true

json.zones(@zones) do |zone|
  json.partial!("spree/api/zones/zone", zone: zone)
end
json.partial! 'spree/api/shared/pagination', pagination: @zones
