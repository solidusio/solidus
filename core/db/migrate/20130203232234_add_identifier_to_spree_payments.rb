class AddIdentifierToSpreePayments < ActiveRecord::Migration
  def change
    add_column :solidus_payments, :identifier, :string
  end
end
