class CreateStoreCreditReimbursementType < ActiveRecord::Migration
  def up
    Solidus::ReimbursementType.create_with(name: Spree.t("store_credit.store_credit")).find_or_create_by!(type: 'Solidus::ReimbursementType::StoreCredit')
  end
end
