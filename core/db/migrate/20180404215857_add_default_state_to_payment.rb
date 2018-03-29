# frozen_string_literal: true

class AddDefaultStateToPayment < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:spree_payments, :state, 'checkout')
  end
end
