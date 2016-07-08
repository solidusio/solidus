object false
child(@payments => :payments) do
  attributes *payment_attributes
end
node(:count) { @payments.count }
node(:current_page) { @payments.current_page }
node(:pages) { @payments.total_pages }
