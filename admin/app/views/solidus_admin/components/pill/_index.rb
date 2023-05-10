# frozen_string_literal: true

module SolidusAdmin::Components::Pill::Index
  include SolidusAdmin::Components::Helpers

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

  def validate_state!(state)
    raise ArgumentError, "Unexpected state: #{state.inspect} (known states are: #{STATES.to_sentence})" unless state.in? STATES
  end
end