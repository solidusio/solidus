# frozen_string_literal: true

require "spree/migration"

class AddTypeBeforeRemovalToSpreePaymentMethods < Spree::Migration
  def change
    add_column :spree_payment_methods, :type_before_removal, :string
  end
end
