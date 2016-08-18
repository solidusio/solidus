class CreateStoreCreditReimbursementType < ActiveRecord::Migration[4.2]
  def up
    Spree::ReimbursementType.create_with(name: Spree.t("store_credit.store_credit")).find_or_create_by!(type: 'Spree::ReimbursementType::StoreCredit')
  end
end
