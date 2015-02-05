class AddCodeToRefundReason < ActiveRecord::Migration
  def change
    add_column :spree_refund_reasons, :code, :string
  end
end
