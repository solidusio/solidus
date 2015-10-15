# This file has the same name as the spree 3.0 migration to prevent it from
# being run twice for those users.
class RenameIdentifierToNumberForPayment < ActiveRecord::Migration
  def change
    rename_column :spree_payments, :identifier, :number
  end
end
