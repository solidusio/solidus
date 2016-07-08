object false
child(@zones => :zones) do
  extends 'spree/api/zones/show'
end
node(:count) { @zones.count }
node(:current_page) { @zones.current_page }
node(:pages) { @zones.total_pages }
