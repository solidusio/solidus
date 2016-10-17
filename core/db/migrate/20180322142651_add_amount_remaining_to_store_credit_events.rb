# frozen_string_literal: true

class AddAmountRemainingToStoreCreditEvents < ActiveRecord::Migration[5.0]
  class StoreCredit < ActiveRecord::Base
    self.table_name = 'spree_store_credits'
    has_many :store_credit_events

    VOID_ACTION       = 'void'
    CREDIT_ACTION     = 'credit'
    CAPTURE_ACTION    = 'capture'
    ELIGIBLE_ACTION   = 'eligible'
    AUTHORIZE_ACTION  = 'authorize'
    ALLOCATION_ACTION = 'allocation'
    ADJUSTMENT_ACTION = 'adjustment'
    INVALIDATE_ACTION = 'invalidate'
  end

  class StoreCreditEvent < ActiveRecord::Base
    self.table_name = "spree_store_credit_events"
    belongs_to :store_credit

    scope :chronological, -> { order(:created_at) }
  end

  def up
    add_column :spree_store_credit_events, :amount_remaining, :decimal, precision: 8, scale: 2, default: nil, null: true

    StoreCredit.includes(:store_credit_events).find_each do |credit|
      credit_amount = credit.amount

      credit.store_credit_events.chronological.each do |event|
        case event.action
        when StoreCredit::ALLOCATION_ACTION,
             StoreCredit::ELIGIBLE_ACTION,
             StoreCredit::CAPTURE_ACTION
          # These actions do not change the amount_remaining so the previous
          # amount available is used (either the credit's amount or the
          # amount_remaining coming from the event right before this one).
          credit_amount
        when StoreCredit::AUTHORIZE_ACTION,
             StoreCredit::INVALIDATE_ACTION
          # These actions remove the amount from the available credit amount.
          credit_amount -= event.amount
        when StoreCredit::ADJUSTMENT_ACTION,
             StoreCredit::CREDIT_ACTION,
             StoreCredit::VOID_ACTION
          # These actions add the amount to the available credit amount. For
          # ADJUSTMENT_ACTION the event's amount could be negative (so it could
          # end up subtracting the amount).
          credit_amount += event.amount
        end

        event.update_attribute(:amount_remaining, credit_amount)
      end
    end
  end

  def down
    remove_column :spree_store_credit_events, :amount_remaining
  end
end
