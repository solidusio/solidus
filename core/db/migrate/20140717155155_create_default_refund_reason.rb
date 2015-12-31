class CreateDefaultRefundReason < ActiveRecord::Migration
  def up
    Solidus::RefundReason.create!(name: Solidus::RefundReason::RETURN_PROCESSING_REASON, mutable: false)
  end

  def down
    Solidus::RefundReason.find_by(name: Solidus::RefundReason::RETURN_PROCESSING_REASON, mutable: false).destroy
  end
end
