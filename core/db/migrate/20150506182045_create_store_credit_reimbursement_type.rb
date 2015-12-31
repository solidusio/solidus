class CreateStoreCreditReimbursementType < ActiveRecord::Migration
  def up
    Solidus::ReimbursementType.create_with(name: Solidus.t("store_credit.store_credit")).find_or_create_by!(type: 'Solidus::ReimbursementType::StoreCredit')
  end
end
