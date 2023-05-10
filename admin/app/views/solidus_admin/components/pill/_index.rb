# frozen_string_literal: true

class SolidusAdmin::Components::Pill::Index < SolidusAdmin::Components::Base
  STATES = %w[
    active
    address
    authorized
    awaiting
    awaiting_return
    backorder
    backordered
    balance_due
    canceled
    cart
    checkout
    complete
    completed
    confirm
    credit_owed
    delivery
    error
    errored
    expired
    failed
    given_to_customer
    in_transit
    inactive
    invalid
    lost_in_transit
    on_hand
    paid
    partial
    payment
    pending
    processing
    ready
    received
    reimbursed
    resumed
    returned
    shipped
    shipped_wrong_item
    short_shipped
    unexchanged
    void
    warning
  ].freeze

  def validate!
    raise ArgumentError, "Unexpected state: #{locals[:state].inspect} (known states are: #{STATES.to_sentence})" unless locals[:state].in? STATES
  end

  def text
    locals[:text] || t(".states.#{state}")
  end
end