class AddPreferenceSourceToSpreePaymentMethods < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_payment_methods, :preference_source, :string
  end
end
