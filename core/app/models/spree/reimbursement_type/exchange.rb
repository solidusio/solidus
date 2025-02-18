# frozen_string_literal: true

class Spree::ReimbursementType::Exchange < Spree::ReimbursementType
  def self.reimburse(reimbursement, return_items, simulate, *_optional_args)
    return [] if return_items.blank?

    exchange = Spree::Exchange.new(reimbursement.order, return_items)
    exchange.perform! unless simulate
    [exchange]
  end
end
