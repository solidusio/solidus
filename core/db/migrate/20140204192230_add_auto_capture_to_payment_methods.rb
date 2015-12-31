class AddAutoCaptureToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :solidus_payment_methods, :auto_capture, :boolean
  end
end
