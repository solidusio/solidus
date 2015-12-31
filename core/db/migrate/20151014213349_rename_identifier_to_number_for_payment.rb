# This file has the same name as the solidus 3.0 migration to prevent it from
# being run twice for those users.
class RenameIdentifierToNumberForPayment < ActiveRecord::Migration
  def change
    rename_column :solidus_payments, :identifier, :number
  end
end
