# Reimbursement types

<!-- TODO:
  This article is a stub. It is not yet a good indicator of how reimbursement
  types should be used, or how they relate to reimbursements and return items.
-->

Each [return item][return-items] should be associated with one of your store's
`Spree::ReimbursementType`s.

By default, the `solidus_backend` interface offers one reimbursement type to
store administrators: `Spree::ReimbursementType::StoreCredit`. When a
`Spree::Reimbursement` is created with this type, a
`Spree::Reimbursement::Credit` is created for the full amount each return item
associated with the reimbursement.

Solidus provides some other [built-in reimbursement types][reimbursement-types]
that you can register and use in your store.

[reimbursement-types]: https://github.com/solidusio/solidus/tree/master/core/app/models/spree/reimbursement_type
[return-items]: return-items.html

## Preferred and override reimbursement types

Each `Spree::ReturnItem` object has the following attributes that link the item
to a reimbursement type:

- `preferred_reimbursement_type_id`: The ID for the reimbursement type that was
  first set for the return item.
- `override_reimbursement_type_id`: An optional reimbursement type that
  overrides the preferred reimbursement type.

When a store administrator is ready to reimburse the customer, they can override
the preferred reimbursement type for another one. This allows store
administrators to change a customer return to satisfy the customer without
losing the history of the customer return.

## Reimbursement types helpers

Solidus's built-in reimbursement types extend the
[`Spree::ReimbursementType::ReimbursementHelpers`
class][reimbursement-helpers-class], which is where much of their core
functionality originates. If you need to make your own reimbursement types, or
you want a better understanding of how reimbursement types work, see the source
code.

[reimbursement-helpers-class]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/reimbursement_type/reimbursement_helpers.rb 
