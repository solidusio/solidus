class AddTypeToReimbursementType < ActiveRecord::Migration
  def change
    add_column :solidus_reimbursement_types, :type, :string
    add_index :solidus_reimbursement_types, :type

    Solidus::ReimbursementType.reset_column_information
    Solidus::ReimbursementType.find_by(name: Solidus::ReimbursementType::ORIGINAL).update_attributes!(type: 'Solidus::ReimbursementType::OriginalPayment')
  end
end
