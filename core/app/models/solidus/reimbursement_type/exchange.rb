# frozen_string_literal: true

class Solidus::ReimbursementType::Exchange < Solidus::ReimbursementType
  def self.reimburse(reimbursement, return_items, simulate, *_optional_args)
    return [] unless return_items.present?

    exchange = Solidus::Exchange.new(reimbursement.order, return_items)
    exchange.perform! unless simulate
    [exchange]
  end
end
