class AddTypeToReimbursementType < ActiveRecord::Migration
  def change
    add_column :spree_reimbursement_types, :type, :string
    add_index :spree_reimbursement_types, :type

    Solidus::ReimbursementType.reset_column_information
    Solidus::ReimbursementType.find_by(name: Solidus::ReimbursementType::ORIGINAL).update_attributes!(type: 'Solidus::ReimbursementType::OriginalPayment')
  end
end
