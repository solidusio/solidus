# frozen_string_literal: true

require "spree/migration"

class AddIndexToSpreePaymentsNumber < Spree::Migration
  def change
    add_index 'spree_payments', ['number'], unique: true
  end
end
