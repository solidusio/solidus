class AddReimbursementIdIndexToSpreeRefunds < ActiveRecord::Migration[4.2]
  def change
    add_index(:spree_refunds, :reimbursement_id)
  end
end
