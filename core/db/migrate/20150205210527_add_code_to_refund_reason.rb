class AddCodeToRefundReason < ActiveRecord::Migration
  def change
    add_column :solidus_refund_reasons, :code, :string
  end
end
