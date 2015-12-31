class ChangeAdjustmentsAmountPrecision < ActiveRecord::Migration
  def change
   
    change_column :solidus_adjustments, :amount,  :decimal, :precision => 10, :scale => 2
                                   
  end
end
