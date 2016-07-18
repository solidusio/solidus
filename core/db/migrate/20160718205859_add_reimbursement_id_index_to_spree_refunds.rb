class AddReimbursementIdIndexToSpreeRefunds < ActiveRecord::Migration
  def change
    add_index(:spree_refunds, :reimbursement_id)
  end
end
