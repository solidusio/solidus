object false
node(:error) { I18n.t(:could_not_transition, scope: "solidus.api.order") }
node(:errors) { @order.errors.to_hash }
