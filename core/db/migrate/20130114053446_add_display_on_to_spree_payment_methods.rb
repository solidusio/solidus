class AddDisplayOnToSpreePaymentMethods < ActiveRecord::Migration
  def self.up
    add_column :solidus_payment_methods, :display_on, :string
  end

  def self.down
    remove_column :solidus_payment_methods, :display_on
  end
end
