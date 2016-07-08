object false
node(:count) { @variants.count }
node(:total_count) { @variants.total_count }
node(:current_page) { @variants.current_page }
node(:pages) { @variants.total_pages }

child(@variants => :variants) do
  extends "spree/api/variants/big"
end
