# frozen_string_literal: true

class AddIndexToSpreePaymentsNumber < ActiveRecord::Migration[5.0]
  def change
    add_index 'spree_payments', ['number'], unique: true
  end
end
