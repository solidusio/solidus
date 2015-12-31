class AddPreferenceSourceToSpreePaymentMethods < ActiveRecord::Migration
  def change
    add_column :solidus_payment_methods, :preference_source, :string
  end
end
