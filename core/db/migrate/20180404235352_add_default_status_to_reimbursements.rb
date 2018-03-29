# frozen_string_literal: true

class AddDefaultStatusToReimbursements < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:spree_reimbursements, :reimbursement_status, 'pending')
  end
end
