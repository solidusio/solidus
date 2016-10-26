# Financial transaction entry for a specific `store_credit`
# it will keep track of the liability and pending transactions.
#
# It will follow the debit and credit rules as described [here](https://en.wikipedia.org/wiki/Debits_and_credits)
# so all debit calls will lower the liability and credit calls will add
# an amount.
#
module Spree
  class StoreCreditLedgerEntry < Spree::Base
    PENDING = :pending
    LIABILITY = :liability

    belongs_to :store_credit
    belongs_to :originator, polymorphic: true

    scope :chronological, -> { order(:created_at) }
    scope :reverse_chronological, -> { order(created_at: :desc) }
    scope :liability, -> { where(liability: true) }
    scope :pending, -> { where(liability: false) }

    delegate :currency, to: :store_credit


    # Will add the amount to the `store_credit`, `credit` the ledger.
    # this amount will always be positive, when there is a need to remove
    # an amount from the `store_credit` you will have to call the [#debit]
    #
    # @param store_credit [Spree::StoreCredit] the store credit for this credit call
    # @param amount [BigDecimal] the amount for the credit, should always be a positive number.
    # @param originator [Object] polymorphic origin that triggered this credit call
    # @param liability_type [Symbol] is either an actual liability change, or a pending transaction
    # @return [Spree::StoreCreditLedgerEntry] the created ledger entry, or an exception when not succesful
    def self.credit(store_credit, amount, originator, liability_type=LIABILITY)
      create!(
        {
          store_credit: store_credit,
          amount: amount,
          originator: originator,
          liability: liability_type == LIABILITY
        }
      )
    end

    # Will remove the amount from the `store_credit`, `debit` the ledger.
    # this amount will always be stored negative, when there is a need to add
    # an amount to the `store_credit` you will have to call the [#credit]
    #
    # @param store_credit [Spree::StoreCredit] the store credit for this credit call
    # @param amount [BigDecimal] the amount for the credit, should always be a positive number.
    # @param originator [Object] polymorphic origin that triggered this credit call
    # @param liability_type [Symbol] is either an actual liability change, or a pending transaction
    # @return [Spree::StoreCreditLedgerEntry] the created ledger entry, or an exception when not succesful
    def self.debit(store_credit, amount, originator, liability_type=LIABILITY)
      # make sure debit amounts are stored as negative number.
      amount = -amount if amount > 0
      create!(
        {
          store_credit: store_credit,
          amount: amount,
          originator: originator,
          liability: liability_type == LIABILITY
        }
      )
    end

    # The balance for a specific `store_credit` is the sum of all
    # pending and liability amounts. This will reflect the available
    # store credits to spend.
    #
    # @param store_credit [Spree::StoreCredit] the store credit that will return his balance
    # @return [BigDecimal] the current total balance for the `store_credit`
    def self.balance(store_credit)
      store_credit.store_credit_ledger_entries.sum(:amount)
    end

    # The liability balance for a specific `store_credit` is the sum of all
    # liability amounts. This is the actual liability amount for the any
    # financial reports
    #
    # @param store_credit [Spree::StoreCredit] the store credit that will return his liability balance
    # @return [BigDecimal] the current total liability balance for the `store_credit`
    def self.liability_balance(store_credit)
      store_credit.store_credit_ledger_entries.liability.sum(:amount)
    end
  end
end
