class AddCodeToRefundReason < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_refund_reasons, :code, :string
  end
end
