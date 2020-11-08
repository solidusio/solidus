# frozen_string_literal: true

class AddTypeBeforeRemovalToSpreePaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_payment_methods, :type_before_removal, :string
  end
end
