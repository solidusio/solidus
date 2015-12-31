class ChangeSolidusReturnAuthorizationAmountPrecision < ActiveRecord::Migration
   def change
   
    change_column :solidus_return_authorizations, :amount,  :decimal, :precision => 10, :scale => 2, :default => 0.0, :null => false
                                   
  end
end
