# frozen_string_literal: true

Spree::Sample.load_sample("orders")

order = Spree::Order.last
inventory_unit = order.inventory_units.take!
stock_location = inventory_unit.find_stock_item.stock_location
return_reason = Spree::ReturnReason.active.take!
preferred_reimbursement_type = Spree::ReimbursementType.where(name: "Original").take!
admin_user = if defined?(Spree::Auth)
  Spree.user_class.admin.take!
else
  Spree.user_class.find_or_create_by!(email: "admin@example.com")
end

# Mark the order paid and shipped
order.payments.pending.each(&:complete)
order.shipments.each do |shipment|
  next if shipment.shipped?

  shipment.suppress_mailer = false
  shipment.ship!
end

# Create a return authorization
return_authorization = order.return_authorizations.first

if return_authorization.nil?
  return_item = Spree::ReturnItem.new(
    inventory_unit:,
    preferred_reimbursement_type:
  )

  return_authorization = order.return_authorizations.create!(
    reason: return_reason,
    return_items: [return_item],
    stock_location:
  )
end

return_item = return_authorization.return_items.first

# Create a customer return and mark it as received
customer_return = return_item.customer_return

if customer_return.nil?
  customer_return = Spree::CustomerReturn.create!(
    return_items: [return_item],
    stock_location:
  )
  return_item.reload
  return_item.receive! unless return_item.received?
  customer_return.process_return!
end

# Accept the customer return and reimburse it
if customer_return.reimbursements.empty?
  reimbursement = Spree::Reimbursement.build_from_customer_return(customer_return)
  reimbursement.return_all(created_by: admin_user)
end
